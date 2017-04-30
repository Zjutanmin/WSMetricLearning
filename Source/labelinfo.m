xx = sum(voteinfo(:,1:2), 2);
id1 = find(xx);
id2 = find(~xx);
length(id1) / (length(id2)+length(id1))
mean(voteinfo(id1,1:2))
mean(voteinfo(id2,3:4))


[mean(votedis(id1,1:6))]
[mean(votedis(id2,7:12))]