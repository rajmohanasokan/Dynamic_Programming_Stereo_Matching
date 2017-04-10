%A script that processes rectified stereo image pair to generate disparity map
%using dynamic programming
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Cox, Ingemar J., Sunita L. Hingorani, Satish B. Rao, and Bruce M. Maggs. 
%"A maximum likelihood stereo algorithm." Computer vision and image understanding 63, 
%no. 3 (1996): 542-567.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clearvars;
% close all;
I_1 = imread('frame_left.png'); %Read Left Image
I_2 = imread('frame_right.png'); %Read Right Image with same size as the Left
[nRow, nCol,nChannel] = size(I_1);
if(nChannel==3)
    I_1 = rgb2gray(I_1);
    I_2 = rgb2gray(I_2);
end
I_1 = im2double(I_1);
I_2 = im2double(I_2);

figure;imshow(I_1);
figure;imshow(I_2);

C = zeros(nCol, nCol);
M = ones(size(C));
displeft = zeros(nRow, nCol);
dispright = zeros(nRow, nCol);
occ = 0.0009; %Occlusion cost
for row = 1:nRow
%     row %To display which row of the image is being processed
    for i=2:nCol
        C(i,1) = i*occ;
    end
    for j = 2:nCol
       C(1,j) = j*occ; 
    end
    for i = 2:nCol
        for j = 2:nCol
           temp = (I_1(row,i)-I_2(row,j))^2;

            min1 = C(i-1,j-1)+temp;
            min2 = C(i-1,j)+occ;
            min3 = C(i,j-1)+occ;
            cmin = min([min1,min2,min3]);
            C(i,j) = cmin; % Cost Matrix
            if(cmin==min1)
                M(i,j) = 1; %Path Tracker
            elseif(cmin==min2)
                M(i,j) = 2;
            elseif(cmin==min3)
                M(i,j) = 3;
            end
        end
    end

    i = nCol;
    j = nCol;
    while(i~=1 && j~=1)

       switch M(i,j)
           case 1
               displeft(row,i) = abs(i-j); % Disparity Image in Left Image coordinates
               dispright(row,j) = abs(j-i); % Disparity Image in Right Image coordinates
               i = i-1;
               j = j-1;
           case 2
               displeft(row,i) = NaN;
               i = i-1;
           case 3
               dispright(row,j) = NaN;
               j = j-1;
       end
    end
    clear C M
end
