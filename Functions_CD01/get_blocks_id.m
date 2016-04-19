function id=get_blocks_id

var=get_param(gcb,'name');
comp=var=='_';

id=str2num(var(find(comp,1,'last')+1:end));
