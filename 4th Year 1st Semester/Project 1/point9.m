clc; clear;
%Data Bits
Legnth_bits=1000;
u=randi([0 1],1,Legnth_bits);
G=zeros(Legnth_bits,Legnth_bits*1.5);
g = [0,1,0,1,1,0;1,1,1,1,0,1];
%The number of input bits to encode
k =2;
%G Matrix of the binary (3,2,2) conv code
j = 1;
for i=1:k:Legnth_bits
        G(i,j:j+5) = g(1,:);
        G(i+1,j:j+5) = g(2,:);
        j = j+3;
end
%codewords
v = u * G;
%remove any none zeros or ones numbers in any codeword
for i=1:length(v)
    if (v(i) >1)
        v(i) = rem(v(i),2);
    end
end