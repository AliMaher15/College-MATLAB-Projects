in=[0.35,0.3,0.2,0.1,0.04,0.005,0.005];
%in=[0.2,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1];
x=sort(in,'descend');
Answer{1,length(x)}=[];
n=1;
h=[0];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Block (1)                               %
%To initialy separate the probalbilities each group sum of    %
%probabilities is more than the next group                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while n 
    for k=1:1:ceil((length(x(1,h(end)+1:end))/2))
        if(sum(x(1,(1+sum(h)):(k+sum(h))))>=sum(x(1,k+1+sum(h):end)))
           % n=0;
            h(end+1)=k;
            break;%%%%%%%% To skip the rest of the instructions in the loop
        end
    end
     if(sum(h)==length(in))
         n=0;
     end 
end
z{1,length(h)-1}=[];%%%store new h values
z{1,1}(1,1)=0;
n=1;
z{1,length(h)-1}=[];%%%store new h values
for i=1:1:length(h)-1
z{1,i}=h;
end
%z{1,1}=h;
h1=[0];
counter=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   Block(2)                        %
% To separate the data within each group keeps      %
% breaking each group elements until it become of   %
% individal elements no longer have smaller groups  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for p=1:1:length(h)-1
x2=x(h(p)+1:h(p)+h(p+1));          
while  z{counter,p}(1,2)>1
    for k=1:1:ceil((length(x2(1,h1(end)+1:end))/2))
        if(sum(x2(1,(1+sum(h1)):(k+sum(h1))))>=sum(x2(1,k+1+sum(h1):end)))
            h1(end+1)=k;
        break;%%%%%%%% To skip the rest of the instructions in the loop
        end
    end
     if(sum(h1)==length(x2))
         n=0;
         counter=counter+1;
         x2=x(1:h1(2));
         z{counter,p}=h1;
         h1=[0];
     end       
end
counter=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   Block(3)                           %
% it gives the data of recent group 0 and the next     %
% groups one and then move to the next group and make  %
% the same process until we finish all groups          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iter=2:1:length(h)
    if(iter==length(h) && h(iter)==1)
        break
    end
  for i1=sum(h(1:iter-1))+1:1:h(iter)+sum(h(1:iter-1))
        Answer{1,i1}(1,end+1)=0;
  end
    for i2=h(iter)+sum(h(1:iter-1))+1:1:length(x)
        Answer{1,i2}(1,end+1)=1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   Block(4)                           %
% it itterate within the same group to  finish the     %
% elements of the group,it works by the same idea of   %
% the previous block                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for p2=1:1:2
    if(h(p2+1)~=1)
for p1=2:1:size(z,1)
    for iter2=2:1:length(z{p1,p2})    
    if(iter2==length(z{p1,p2}) && z{p1,p2}(iter2)==1) 
        break;
    end
  for p11=sum(z{p1,p2}(1:iter2-1))+1+h(p2):1:z{p1,p2}(iter2)+sum(z{p1,p2}(1:iter2-1)+h(p2))
        Answer{1,p11}(1,end+1)=0;
  end
    for p12=z{p1,p2}(iter2)+sum(z{p1,p2}(1:iter2-1))+1+h(p2):1:sum(z{p1,p2})+h(p2)
        Answer{1,p12}(1,end+1)=1;
    end
    end
end
    end
end