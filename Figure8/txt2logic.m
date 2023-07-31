function [CR]=txt2logic(Y)

charY=char(Y);
for i=1:length(Y)
   if charY(i,:)== 'Correct Choice'
       CR(i,1)= 1;
   else
       CR(i,1)=0;
   end
end
CR=logical(CR);
end