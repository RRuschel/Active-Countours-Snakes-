% University of California, Santa Barbara
% Winter 2015
% CS/ECE 181b
% Homework 2
% Raphael Ruschel dos Santos

clear all
clc

sigma = 3;
w_size = ceil((sigma*3))*2 + 1;
h = fspecial('gaussian',w_size,sigma);
load('coordinates2.mat') %Load the coordinates of the template
t = 1:10;
n = 1:0.1:10;
X = spline(t,X,n);
Y = spline(t,Y,n);

alfa = 0.001; %Setting the parameters
beta = 0.4;
gamma = 1;
matrix = zeros(length(X),length(Y));
Wline = 0.1;
Wedge = 1;
iterations = 80;

matrix(1,1) = (2*alfa+6*beta); %Create the matrix
matrix(1,2) = (-alfa-4*beta);
matrix(1,3) = beta;
matrix(1,length(X)) = matrix(1,2);
matrix(1,length(X)-1) = matrix(1,3);
for i=2:length(Y)
    matrix(i,:) = circshift(matrix(i-1,:)',[1 0]);
end

% directory = input('Type the source directory\n','s');
% cd(directory)
root = input('Type the image name\n','s');
idx1 = input('Type the starting index\n','s');
idx2 = input('Type the final index\n','s');
startImage = [root '_' idx1 '.jpg'];
finalImage = [root '_' idx2 '.jpg'];
d = dir('*.jpg');

for i=1:length(d) %Get the image index based on the named passed on the parameters
    if(d(i).name == startImage)
        startIndex = i;
    end
    if(d(i).name == finalImage)
        finalIndex = i;
        break;
    end
end


for i=startIndex:finalIndex %Browse the images from idx1 to idx2
    pic_name = d(i).name;
    originalPic = imread(pic_name);
    pic = rgb2gray(originalPic);
    pic = imfilter(pic,h);
    imshow(originalPic)
    hold on
      
    pic = double(pic);
    [Gx,Gy] = gradient(pic);
    Eedge = -sqrt(Gx.*Gx + Gy.*Gy); %Calculate Edge energy
    Eline = Wline.*pic;
    Eline = double(Eline);
    Eext = Eline + Wedge.*Eedge; %Calculate External energy
    
    [Gx,Gy] = gradient(Eext);
    
 
    for j=1:iterations %Do the iterations to calculate the new snake position
        Fx = interp2(1:size(Gx,2),1:size(Gy,1),Gx,X,Y);
        Fy = interp2(1:size(Gx,2),1:size(Gy,1),Gy,X,Y);
        X = (matrix+gamma*eye(size(matrix)))\(gamma*X-Fx)'; %Calculate new snake points
        Y = (matrix+gamma*eye(size(matrix)))\(gamma*Y-Fy)';
        X = X';
        Y = Y';
    end
        result = plot(X,Y,'b'); %Plot the new result on top of the original image
        title(pic_name)
        pause(0.001)
        delete(result)
    %end
end

  

