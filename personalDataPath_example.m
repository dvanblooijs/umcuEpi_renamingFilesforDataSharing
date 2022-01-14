
%% THIS IS AN EXAMPLE FILE
% copy this one and fill in your own

function [localDataPath,cfg] = personalDataPath_example()

% function that contains local data path, is ignored in .gitignore

localDataPath.shareFolder = '/directory/with/data/to/share/';

% use this if you want to convert electrode positions to a standard brain
% (MNI space) electrode positions
localDataPath.freesurfer = '/directory/to/folder/with/derivatives/freesurfer/';

% % % set paths
fieldtrip_folder  = '/directory/to/fieldtrip/';
% % copy the private folder in fieldtrip to somewhere else
fieldtrip_private = '/directory/to/fieldtrip_private/';
addpath(fieldtrip_folder)
addpath(fieldtrip_private)
ft_defaults

jsonlab_folder = '/directory/to/jsonlab/';
addpath(jsonlab_folder)


%% name recognizable part of a file of which the content should be evaluated

cfg(1).filename = {'electrodes.tsv'};
cfg(2).filename = {'N1sChecked.mat'};

%% name the fields that should be add to the final version of a file

% all fields in electrodes.tsv:
%    {'name','x','y','z','size','material','manufacturer','group',...
%     'hemisphere','silicon','soz','resected','edge','DKT_label',...
%     'DKT_label_text','Destrieux_label','Destrieux_label_text','Wang_label',...
%     'Wang_label_text','Benson_label','Benson_label_text','Benson_eccen',...
%     'Benson_polarangle','Benson_sigma'};

cfg(1).reqFields = {'name','group','silicon','soz','resected','edge'}; % accompanies cfg(1).filename
cfg(2).reqFields = {'n1_peak_sample','amplitude_thresh','n1_peak_range','dataName','ch',...
    'cc_stimchans','cc_stimsets','epoch_length','epoch_prestim','dir','amp','reref'}; % accompanies cfg(2).filename

end