tt = 4:4:1000;
ent = ones(length(tt),3);
ent(:,1)=tt;
save event.txt -ascii ent
