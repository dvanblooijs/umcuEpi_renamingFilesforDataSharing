%% renaming files
% author: Dorien van Blooijs
% date: May 2021

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

% Make sure the user wants to annonimize TRC files when they are in the
% fileList. In principle only BIDS-format files are shared. 
checkTRC = 0;
if any(contains(fileList,'.TRC'))
    replyTRC = input('NOTE: Only BIDS-format files should be shared. \nAre you sure you want to rename .TRC files? [y/n]: ','s');
    if strcmpi(replyTRC,'y')
        checkTRC =  1;
    end
end

% remove the key.xlsx from the fileList to be converted
idx = contains(fileList,'key');
fileList(idx) = [];

% run through all files
for i = 1:size(fileList,1)
    foundKey = 0;

    % run through all keys
    for j=1:size(key,1)
        
        % find matching key
        if contains(fileList(i),key(j,1))
            foundKey = 1; % in case there is a matching key

            [nameDir, nameFile, nameExt] = fileparts(fileList{i});
            
            indivkey = key{j,1}; renamekey = key{j,2};
            renameFileVar(fileList{i},indivkey,renamekey,checkTRC)
            
            % move file to new location
            newname = replace(fileList{i},key{j,1},key{j,2});
            [newnameDir,newnameFile,newnameExt] = fileparts(newname);
            
            % make directory if it does not exist yet
            if ~exist(newnameDir,'dir')
                mkdir(newnameDir)
            end
            
            movefile(fileList{i},newname)
%              copyfile(fileList{i},newname)

            % if directory is empty, delete directory
            if isempty(getAllFiles(nameDir))
                rmdir(nameDir)
            end

        end
    end
    if foundKey == 0 % there is no original patient name in the filename, but we need to check whether there are no patient names within the file (for example in participants.tsv)
        renameFileContent(fileList{i},key)
    end
end

%% change content of specific files (uses cfg.reqFields defined in personalDataPath.m)
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

%% change electrode positions in electrodes.tsv to MNI space (instead of positions on the individual brain)

idx = contains(fileList,'electrodes.tsv')==0;

fileList_elec = fileList;
fileList_elec(idx) = [];

for subj = 1:size(fileList_elec,1)

    convertElec2MNI(myDataPath,fileList_elec{subj},key);

end

disp('Conversion to MNI space is completed.')