function uid = root(tree)
% XMLTREE/ROOT Root Method
% FORMAT uid = root(tree)
% 
% tree   - XMLTree object
% uid    - UID of the root element of tree
%__________________________________________________________________________
%
% Return the uid of the root element of the tree.
%__________________________________________________________________________
% Copyright (C) 2002-2008  http://www.artefact.tk/

% Guillaume Flandin
% $Id: root.m 8183 2021-11-04 15:25:19Z guillaume $

% Actually root is necessarily the element whose UID is 1, by
% construction. However, xml_parser should return a tree with a ROOT
% element with as many children as needed but only ONE *element* child
% who would be the real root (and this method should return the UID of
% this element).

uid = 1;

% Update:
% xml_parser has been modified (not as explained above) to handle the
% case when several nodes are at the top level of the XML.
% Example: <!-- beginning --><root>blah blah</root><!-- end -->
% Now root is the first element node of the tree.

% Look for the first element in the XML Tree
for i=1:length(tree)
    if strcmp(get(tree,i,'type'),'element')
        uid = i;
        break
    end
end
