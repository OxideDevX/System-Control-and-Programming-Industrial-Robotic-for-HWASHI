
heightmapColorDir = '../data/heightmap-color';
heightmapDepthDir = '../data/heightmap-depth';
labelDir = '../data/label';
labelFiles = dir(fullfile(labelDir,'*.good.txt'));
targetDir = './training';

mkdir(fullfile(targetDir,'color'));
mkdir(fullfile(targetDir,'depth'));
mkdir(fullfile(targetDir,'label-aug'));
mkdir(fullfile(targetDir,'label'));

for sampleIdx = 1:length(labelFiles)
    sampleName = sprintf('%06d.png',sampleIdx-1);

    heightmapColor = uint8(zeros(320,320,3));
    heightmapColor(49:272,1:320,:) = imread(fullfile(heightmapColorDir,sampleName));
    heightmapDepth = uint16(zeros(320,320));
    heightmapDepth(49:272,1:320) = imread(fullfile(heightmapDepthDir,sampleName));

    try
        goodGraspPixLabels = dlmread(fullfile(labelDir,sprintf('%06d.good.txt',sampleIdx-1))); % x1,y1,x2,y2 format
    catch
        goodGraspPixLabels = [];
    end
    try
        badGraspPixLabels = dlmread(fullfile(labelDir,sprintf('%06d.bad.txt',sampleIdx-1)));
    catch
        badGraspPixLabels = [];
    end

    goodGraspPixLabels(:,2:2:end) = goodGraspPixLabels(:,2:2:end)+48;
    badGraspPixLabels(:,2:2:end) = badGraspPixLabels(:,2:2:end)+48;
    
    figure(1); imshow(heightmapColor);
    
    goodGraspLabels = uint8(zeros(40,40,16));
    for graspIdx = 1:size(goodGraspPixLabels,1)
        hold on; plot([goodGraspPixLabels(graspIdx,1);goodGraspPixLabels(graspIdx,3)], ...
                      [goodGraspPixLabels(graspIdx,2);goodGraspPixLabels(graspIdx,4)]); hold off;
        graspSampleCenter = mean([goodGraspPixLabels(graspIdx,1:2);goodGraspPixLabels(graspIdx,3:4)]); % Compute grasping location
        graspSampleCenterDownsample = round((graspSampleCenter-1)./8+1); % Downsample grasping location
        
        graspDirection = (goodGraspPixLabels(graspIdx,1:2)-goodGraspPixLabels(graspIdx,3:4))./norm((goodGraspPixLabels(graspIdx,1:2)-goodGraspPixLabels(graspIdx,3:4)));
        diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0); % angle to 1,0
        while diffAngle < 0
            diffAngle = diffAngle+360;
        end
        
        rotIdx = round(diffAngle/(45/2)+1);
        goodGraspLabels(graspSampleCenterDownsample(2),graspSampleCenterDownsample(1),rotIdx) = 1;
        rotIdx = mod(rotIdx-1+8,16)+1;
        goodGraspLabels(graspSampleCenterDownsample(2),graspSampleCenterDownsample(1),rotIdx) = 1;
    end
    
    badGraspLabels = uint8(zeros(40,40,16));
    for graspIdx = 1:size(badGraspPixLabels,1)
        graspSampleCenter = mean([badGraspPixLabels(graspIdx,1:2);badGraspPixLabels(graspIdx,3:4)]); 
        graspSampleCenterDownsample = round((graspSampleCenter-1)./8+1); 
        
        graspDirection = (badGraspPixLabels(graspIdx,1:2)-badGraspPixLabels(graspIdx,3:4))./norm((badGraspPixLabels(graspIdx,1:2)-badGraspPixLabels(graspIdx,3:4)));
        diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0); 
        while diffAngle < 0
            diffAngle = diffAngle+360;
        end
        
        rotIdx = round(diffAngle/(45/2)+1);
        badGraspLabels(graspSampleCenterDownsample(2),graspSampleCenterDownsample(1),rotIdx) = 1;
        rotIdx = mod(rotIdx-1+8,16)+1;
        badGraspLabels(graspSampleCenterDownsample(2),graspSampleCenterDownsample(1),rotIdx) = 1;
    end

    for rotIdx = 1:16
        rotAngle = 360-(rotIdx-1)*(45/2);
        
        sampleHeightmapColor = imrotate(heightmapColor,rotAngle,'crop');
        sampleHeightmapDepth = imrotate(heightmapDepth,rotAngle,'crop');
        sampleHeightmapLabel = uint8(ones(40,40).*255);
        sampleHeightmapLabelAug = uint8(ones(40,40).*255);
        goodGraspInd = imrotate(goodGraspLabels(:,:,rotIdx),rotAngle,'crop')>0;
        badGraspInd = imrotate(badGraspLabels(:,:,rotIdx),rotAngle,'crop')>0;
        
        goodGraspIndAug = imdilate(imdilate(goodGraspInd,strel('line',3,90)),strel('line',3,0)) | ...
                                imdilate(goodGraspInd,strel('line',5,90));
        badGraspIndAug = imdilate(imdilate(badGraspInd,strel('line',3,90)),strel('line',3,0)) | ...
                               imdilate(badGraspInd,strel('line',5,90));
        
        sampleHeightmapLabel(badGraspInd) = 0;
        sampleHeightmapLabel(goodGraspInd) = 128;
        sampleHeightmapLabelAug(badGraspIndAug) = 0;
        sampleHeightmapLabelAug(goodGraspIndAug) = 128;
        
        imwrite(sampleHeightmapColor,fullfile(targetDir,'color',sprintf('%06d-%02d.png',sampleIdx-1,rotIdx-1)));
        imwrite(sampleHeightmapDepth,fullfile(targetDir,'depth',sprintf('%06d-%02d.png',sampleIdx-1,rotIdx-1)));
        imwrite(sampleHeightmapLabel,fullfile(targetDir,'label',sprintf('%06d-%02d.png',sampleIdx-1,rotIdx-1)));
        imwrite(sampleHeightmapLabelAug,fullfile(targetDir,'label-aug',sprintf('%06d-%02d.png',sampleIdx-1,rotIdx-1)));
        
        if mod(sampleIdx,5) == 0
            fprintf(testSplitFid,sprintf('%s\n',sprintf('%06d-%02d',sampleIdx-1,rotIdx-1)));
        else
            if sum(sampleHeightmapLabel(:) < 255) > 0
                fprintf(trainSplitFid,sprintf('%s\n',sprintf('%06d-%02d',sampleIdx-1,rotIdx-1)));
            end
        end
        
        figure(2); subplot(4,4,rotIdx); imshow(sampleHeightmapColor);
        figure(3); subplot(4,4,rotIdx); imshow(sampleHeightmapLabel);
    end
    pause(0.1);
end

fclose(trainSplitFid);
fclose(testSplitFid);