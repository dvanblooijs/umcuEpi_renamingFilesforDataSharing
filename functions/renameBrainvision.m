function renameBrainvision(filename,indivkey, renamekey)

fileorigEEG = filename;
filenewEEG = replace(fileorigEEG,indivkey{:},renamekey{:});
filenewVHDR = replace(filenewEEG,'.eeg','.vhdr');

%% create Brainvision format from TRC

temp = [];
temp.dataset                     = filename;
temp.continuous = 'yes';
data2write = ft_preprocessing(temp);

temp = [];
temp.outputfile                  = filenewVHDR;

temp.method = 'convert';
temp.writejson = 'no';
temp.writetsv = 'no';
temp.ieeg.writesidecar = 'no';

% write .vhdr, .eeg, .vmrk
data2bids(temp, data2write)

end