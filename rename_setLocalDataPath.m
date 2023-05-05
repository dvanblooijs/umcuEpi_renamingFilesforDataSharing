
function [localDataPath,cfg] = rename_setLocalDataPath(varargin)

% function LocalDataPath = setLocalDataPath(varargin)
% Return the path to the root CCEP  directory and add paths in this repo
%
% input:
%   personalDataPath: optional, set to 1 if adding personalDataPath
%
% when adding personalDataPath, the following function should be in the
% root of this repo:
%
% function localDataPath = rename_personalDataPath()
%     'localDataPath = [/my/path/to/data];
%
% this function is ignored in .gitignore
%
% dvanblooijs, 2020, UMCU_EpiLAB

if isempty(varargin)

    rootPath = which('rename_setLocalDataPath');
    RepoPath = fileparts(rootPath);
    
    % add path to functions
    addpath(genpath(RepoPath));
    
    % add localDataPath default
    localDataPath = fullfile(RepoPath,'data');

elseif ~isempty(varargin)
    % add path to data
    if isstruct(varargin{1})
        localDataPath = rename_personalDataPath(varargin{1});
    else
        if varargin{1}==1 && exist('rename_personalDataPath','file')
            
            [localDataPath,cfg] = rename_personalDataPath();
            
        elseif varargin{1}==1 && ~exist('rename_personalDataPath','file')
            
            sprintf(['add rename_personalDataPath function to add your localDataPath:\n'...
                '\n'...
                'function localDataPath = rename_personalDataPath()\n'...
                'localDataPath.input = [/my/path/to/data];\n'...
                'localDataPath.output = [/my/path/to/output];\n'...
                '\n'...
                'this function is ignored in .gitignore'])
            return
        end
    end
    
    % add path to functions
    rootPath = which('rename_setLocalDataPath');
    RepoPath = fileparts(rootPath);
    addpath(genpath(RepoPath));
    
end

return

