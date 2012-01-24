function [jobid, puttime] = peerfeval(varargin)

% PEERFEVAL execute the specified function on another peer.
%
% Use as
%   jobid  = peerfeval(fname, arg1, arg2, ...)
%   argout = peerget(jobid, ...)
%
% This function has a number of  optional arguments that have to passed
% as key-value pairs at the end of the list of input arguments. All other
% input arguments (including other key-value pairs) will be passed to the
% function to be evaluated.
%   timeout  = number, in seconds (default = inf)
%   sleep    = number, in seconds (default = 0.01)
%
% Example
%   jobid = peerfeval('unique', randn(1,10));
%   argout = peerget(jobid, 'timeout', inf);
%   disp(argout);
%
% See also PEERGET, PEERCELLFUN, PEERMASTER, PEERSLAVE, FEVAL, DFEVAL, DFEVALASYNC

% Undocumented options
%   memreq   default = 0
%   cpureq   default = 0
%   timreq   default = 0
%   hostid
%   diary

% -----------------------------------------------------------------------
% Copyright (C) 2010, Robert Oostenveld
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/
% -----------------------------------------------------------------------

% Undocumented
%   hostid   = number, only evaluate on a particular host

% these are used to speed up the processing of multiple function calls with
% the same input arguments (e.g. from peercellfun)
persistent previous_argin

% the peer server must be running in master mode
peer('status', 1);

% check the current status of the maintenance threads
threads = true;
threads = threads && peer('announce', 'status');
threads = threads && peer('discover', 'status');
threads = threads && peer('expire',   'status');
threads = threads && peer('tcpserver', 'status');
% threads = threads && peer('udsserver', 'status');

if ~threads
  % start the maintenance threads
  ws = warning('off');
  peer('announce',  'start');
  peer('discover',  'start');
  peer('expire',    'start');
  peer('tcpserver', 'start');
  % peer('udsserver', 'start');
  warning(ws);
  % wait some time to ensure that all peers on the network have been found
  pause(1.5);
end

% keep track of the time
stopwatch = tic;

% convert the input arguments into something that strmatch can work with
strargin = varargin;
strargin(~cellfun(@ischar, strargin)) = {''};

% locate the begin of the optional key-value arguments
optbeg = false(size(strargin));
optbeg = optbeg | strcmp('timeout', strargin);
optbeg = optbeg | strcmp('sleep',   strargin);
optbeg = optbeg | strcmp('memreq',  strargin);
optbeg = optbeg | strcmp('cpureq',  strargin);
optbeg = optbeg | strcmp('timreq',  strargin);
optbeg = optbeg | strcmp('hostid',  strargin);
optbeg = optbeg | strcmp('diary',   strargin);
optbeg = find(optbeg);
optarg = varargin(optbeg:end);

% get the optional input arguments
timeout = ft_getopt(optarg, 'timeout', inf);
sleep   = ft_getopt(optarg, 'sleep',   0.05);
memreq  = ft_getopt(optarg, 'memreq',  0);
cpureq  = ft_getopt(optarg, 'cpureq',  0);
timreq  = ft_getopt(optarg, 'timreq',  0);
hostid  = ft_getopt(optarg, 'hostid',  []);
diary   = ft_getopt(optarg, 'diary',   []);

% skip the optional key-value arguments
if ~isempty(optbeg)
  varargin = varargin(1:(optbeg-1));
end

if isa(varargin{1}, 'function_handle')
  % convert the function handle back into a string (e.g. @plus should be 'plus')
  varargin{1} = func2str(varargin{1});
end

if ~isempty(previous_argin) && ~isequal(varargin{1}, previous_argin{1})
  % this can be skipped if the previous call used the same function
  if isempty(which(varargin{1}))
    error('Not a valid M-file (%s).', varargin{1});
  end
end

% start with empty return values
jobid   = [];
puttime = [];

% each job should have a different random number sequence
randomseed = rand(1)*double(intmax);

% pass some options that influence the remote execution
options = {'pwd', getcustompwd, 'path', getcustompath, 'global', getglobal, 'diary', diary, 'memreq', memreq, 'cpureq', cpureq, 'timreq', timreq, 'randomseed', randomseed};

% status = 0 means zombie mode, don't accept anything
% status = 1 means master mode, accept everything
% status = 2 means idle slave, accept only a single job
% status = 3 means busy slave, don't accept a new job

while isempty(jobid)
  
  if toc(stopwatch)>timeout
    % it took too long to find a peer that was willing to execute the job
    break;
  end
  
  % get the full list of peers
  list = peerlist;
  
  if ~isempty(hostid)
    % only consider peers in the user specified list
    list = list(ismember([list.hostid], hostid));
  end
  
  % only peers that are currently in idle or busy slave mode are interesting
  list = list([list.status]==2 | [list.status]==3);
  if isempty(list)
    error('there is no peer available as slave');
  end
  
  % only peers with enough memory are interesting
  list = list([list.memavail] >= memreq);
  if isempty(list)
    error('there are no slave peers available that meet the memory requirements');
  end
  
  % only peers with enough CPU speed are interesting
  list = list([list.cpuavail] >= cpureq);
  if isempty(list)
    error('there are no slave peers available that meet the CPU requirements');
  end
  
  % only peers with enough time for a single job are interesting
  list = list([list.timavail] >= timreq);
  if isempty(list)
    error('there are no slave peers available to execute a job of this duration');
  end
  
  % only the idle slaves are interesting from now on
  % the busy slaves may again become relevant on the next attempt
  list = list([list.status] == 2);
  
  if isempty(list)
    % at the moment all the appropriate slaves are busy
    % give the peer network some time to recover
    pause(sleep);
    continue;
  end
  
  list = peerschedule(list, memreq, timreq, cpureq);
  
  for i=1:length(list)
    try
      jobid   = [];
      puttime = toc(stopwatch);
      result  = peer('put', list(i).hostid, varargin, options, 'memreq', memreq, 'timreq', timreq);
      puttime = toc(stopwatch) - puttime;
      jobid   = result.jobid;
      % the peer accepted the job, there is no need to continue with the for loop
      % fprintf('submitted job to %s@%s:%d\n', list(i).user, list(i).hostname, list(i).port);
      break;
    catch
      % the peer rejected the job, perhaps because it is busy or perhaps because of allowuser/allowgroup/allowhost
    end
  end % for
  
  if isempty(jobid)
    % the job was not submitted succesfully and another attempt is needed
    % give the peer network some time to recover
    pause(sleep);
    continue;
  end
  
end % while isempty(jobid)

if isempty(jobid)
  warning('FieldTrip:peer:noSlaveAvailable', 'none of the slave peers was willing to accept the job');
end

% remember the input arguments to speed up subsequent calls
previous_argin  = varargin;
