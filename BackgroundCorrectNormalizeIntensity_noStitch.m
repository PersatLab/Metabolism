PROMPT='Do you want to process a file (press 1) or a folder (press 2)?';
f=input(PROMPT);
if f==1

    % choose tiff stack file
    [FileTif,path] = uigetfile('*.tif');
    %
%     LoadImage(path,FileTif) %run local function LoadImage
    
    % load image
    
      cd (path)
    info = imfinfo(strcat(path,FileTif));

    % load tiff stack
    InfoImage=imfinfo(FileTif);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);
    if info(1).BitDepth==8
        FinalImage=zeros(nImage,mImage,NumberImages,'uint8');
    end
    if info(1).BitDepth==16
        FinalImage=zeros(nImage,mImage,NumberImages,'uint16');
    end

    disp(['loading data...'])
    disp(['processing: ' FileTif])
    TifLink = Tiff(FileTif, 'r');
    for i=1:NumberImages
       TifLink.setDirectory(i);
       FinalImage(:,:,i)=TifLink.read();
       disp([num2str(i),'...'])
    end
end
% get the minimum intensity value for each pixel in the stack and subtract
% this from the stack to remove background
Imin=min(FinalImage,[],3);
for i=1:size(FinalImage,3)
    FinalImage(:,:,i)=FinalImage(:,:,i)-Imin;
end
for i=1:size(FinalImage,3)
    IntensitySum(i,1)=sum(sum(FinalImage(:,:,i)));
end

% use the average instead of sum
for i=1:size(FinalImage,3)
    IntensityAve(i,1)=mean(mean(FinalImage(:,:,i)));
end

% column 3 = average of 2 images at same distance
IntensitySum2=IntensitySum(1:20);
IntensitySum2(1:20,2)=flipud(IntensitySum(21:40));
IntensitySum2(:,3)=mean(IntensitySum2(:,1:2),2);
IntensitySum2(:,3)=IntensitySum2(:,3)-min(IntensitySum2(:,3));
IntensitySum2(:,3)=IntensitySum2(:,3)./max(IntensitySum2(:,3));

k=0;
for i=1:size(FinalImage,3)
    for j=1:size(FinalImage,2)
        k=k+1;
        meanKym(k,1)=mean(FinalImage(:,j,i));
    end
end

meanKym2=meanKym(1:size(meanKym,1)/2);
meanKym2(:,2)=flipud(meanKym((size(meanKym,1)/2)+1:end));
meanKym2(:,3)=mean(meanKym2(:,1:2),2);


csvwrite(strcat(FileTif(1:end-3),'csv'),IntensitySum2)