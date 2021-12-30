%% renaming files
% author: Dorien van Blooijs, Eline Schaft
% date: December 2021

clc
clear
[myDataPath,cfg] = setLocalDataPath(1);

%% load key for renaming:
% this file should be named key.xlsx, and in the first column, it should
% contain the original name, in the second column, it should contain the
% name that should replace the original name

dirName = myDataPath.shareFolder;
key = readcell(fullfile(dirName,'key.xlsx'));

%% get all files in a specific directory

fileList = getAllFiles(dirName);

%% rename variables containing the name and move them to new named directory

% run through all files
for i = 1:size(fileList,1)
    
    % run through all keys
    for j=1:size(key,1)
        
        % find matching key
        if contains(fileList(i),key(j,1))
            
            [nameDir, nameFile, nameExt] = fileparts(fileList{i});
            
            % Copy original to  folder 'Original'
            pathOriginal = [nameDir, '/Original'];
            if ~exist(pathOriginal,'dir')
                mkdir(pathOriginal)
            end
            fileOriginal = fullfile(pathOriginal,[nameFile, nameExt]);
            copyfile(fileList{i},fileOriginal);

            indivkey = key{j,1}; renamekey = key{j,2};
            renameFileVar(fileList{i},indivkey,renamekey)
            
            % move file to new location
            newname = replace(fileList{i},key{j,1},key{j,2});
            [newnameDir,newnameFile,newnameExt] = fileparts(newname);
            
            % make directory if it does not exist yet
            if ~exist(newnameDir,'dir')
                mkdir(newnameDir)
            end
            
            movefile(fileList{i},newname)
            
            % if directory is empty, delete directory
            if isempty(getAllFiles(nameDir))
                rmdir(nameDir)
            end
        end
    end
end

%% change content of specific files
reduceFiles = input('Do you want to reduce the variables in some specific files, and did you specify this in personalDataPath.m? [y/n]: ','s');

if strcmp(reduceFiles,'y')
    % get all files
    fileList = getAllFiles(dirName);
    
    % change what specific files should contain
    
    for j = 1:size(cfg,2)
        
        for i = 1:size(fileList,1)
            clear Variable newVariable Variable_tsv
            
            if contains(fileList{i},cfg(j).filename{1})
                
                [~,~,fileExt] = fileparts(fileList{i});
                
                if strcmp(fileExt,'.tsv')
                    % load file
                    Variable = readtable(fileList{i},'FileType','text','Delimiter','\t');
                    
                    % add all columns that are required
                    for k = 1:size(cfg(j).reqFields,2)
                        newVariable.(cfg(j).reqFields{k}) = Variable.(cfg(j).reqFields{k});
                    end
                    
                    % make struct into table
                    Variable_tsv = struct2table(newVariable);
                    
                    % save table
                    writetable(Variable_tsv, fileList{i}, 'Delimiter', 'tab', 'FileType', 'text');
                    
                elseif strcmp(fileExt,'.mat')
                    % load file
                    Variable = load(fileList{i});
                    
                    % add all columns that are required
                    for k = 1:size(cfg(j).reqFields,2)
                        newVariable.(cfg(j).reqFields{k}) = Variable.(cfg(j).reqFields{k});
                    end
                    
                    % save mat-file
                    save(fileList{i},'-struct','newVariable')
                    
                else
                    warning('For this file %s, no code has been written yet',fileList{i})
                    
                end
            end
        end
    end
end
