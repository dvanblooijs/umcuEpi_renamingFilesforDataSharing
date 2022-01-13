function write_json(filename, json)
json = remove_empty(json);
ft_info('writing %s\n', filename);
if ft_hastoolbox('jsonlab', 3)
    opt.ParseLogical = 1; % logical array elem will use true/false rather than 1/0.
    opt.FileName = filename;
    savejson('', json, opt);
else
    str = jsonencode(json);
    fid = fopen(filename, 'w');
    fwrite(fid, str);
    fclose(fid);
end
