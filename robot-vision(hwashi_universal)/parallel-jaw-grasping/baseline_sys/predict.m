% 3D анализатор(активируеться при сварке объемных изделий, для работы нужна 3D камера)
% Для работы 3D камеры обязательно наличие драйверов от изготовителя камеры(можно загрузить на официальном сайте, в source code)/

function [graspPredictions,flushGraspPredictions] = predict(heightmap)
voxelSize = 0.002;       
fingerWidth = 0.06;       
fingerThickness = 0.036;  

graspPredictions = [];
flushGraspPredictions = [];
% скорость и размер считывания(абсолютные константы)
heightmapSize = size(heightmap);
graspRotations = 0:deg2rad(45/2):deg2rad(179);

[topFingerInitX,topFingerInitY] = meshgrid(1:(fingerWidth/voxelSize),(fingerThickness/voxelSize):-1:1);
[botFingerInitX,botFingerInitY] = meshgrid(1:(fingerWidth/voxelSize),1:(fingerThickness/voxelSize));

for dx = 5:25
    for dy = 6:15
        localHeightMap = heightmap((dy*10-9):(dy*10),(dx*10-9):(dx*10));
        if sum(localHeightMap(:) > 0) > 75
            xCoord = dx*10-5;
            yCoord = dy*10-5;
            xyCoordRep = repmat([xCoord;yCoord],1,size(topFingerInitX(:),1));
            medianLocalHeightmap = median(localHeightMap(:));
 
            for theta = graspRotations
                rotMat = [cos(theta),-sin(theta);sin(theta),cos(theta)];
                topFingerShiftedX = topFingerInitX - (fingerWidth/voxelSize)/2;
                botFingerShiftedX = botFingerInitX - (fingerWidth/voxelSize)/2;
                
                for graspWidth = 0.03:0.02:0.11
                    graspWidthPix = (graspWidth/voxelSize)/2;
                    topFingerShiftedY = topFingerInitY + graspWidthPix;
                    topFingerPix = [topFingerShiftedX(:),topFingerShiftedY(:)];
                    botFingerShiftedY = -botFingerInitY - graspWidthPix;
                    botFingerPix = [botFingerShiftedX(:),botFingerShiftedY(:)];
                    topFingerPix = round(rotMat * topFingerPix' + xyCoordRep)';
                    botFingerPix = round(rotMat * botFingerPix' + xyCoordRep)';
                    fingerInd = sub2ind2d(heightmapSize, [topFingerPix(:,2);botFingerPix(:,2)],[topFingerPix(:,1);botFingerPix(:,1)]);

                    if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                        continue;
                    end

                    fingerIndHeightmap = heightmap(fingerInd);
                    if medianLocalHeightmap > median(fingerIndHeightmap) + 0.02 && ...  
                       medianLocalHeightmap > prctile(fingerIndHeightmap,90) + 0.02     
                        [midGraspX,midGraspY] = meshgrid(1:(fingerWidth/voxelSize),1:(graspWidth/voxelSize));
                        midGraspX = midGraspX - (fingerWidth/voxelSize)/2;
                        midGraspY = midGraspY - (graspWidth/voxelSize)/2;
                        midGraspPix = [midGraspX(:),midGraspY(:)];
                        midGraspPix = round(rotMat * midGraspPix' + repmat([xCoord;yCoord],1,size(midGraspPix,1)))';  
                        graspInd = sub2ind2d(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));
                        surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                        graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                        graspPtsPix = [topFingerPix(18*16,:),botFingerPix(18*15+1,:)];
                       
                        colorMapJet = jet;
                        colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                        hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                        
                        graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                        graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                        diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0); 
                        while diffAngle < 0
                            diffAngle = diffAngle+360;
                        end
                        rotIdx = mod(round(diffAngle/(45/2)),8); 
                        graspPredictions = [graspPredictions;[graspCenterPix,rotIdx,graspConf]];
                        
             
                        break; 
                    end
                end
            end
        end
    end
end

for dx=5:25
    
    
    for dy = [4,5]
        localHeightMap = heightmap((dy*10-9):(dy*10),(dx*10-9):(dx*10));
        if sum(localHeightMap(:) > 0) > 75
            xCoord = dx*10-5;
            yCoord = dy*10-5;
            medianLocalHeightmap = median(localHeightMap(:));
          
            for graspWidth = 0.03:0.02:0.11
                [botFingerShiftedX,botFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(21+(graspWidth/voxelSize)):(20+(graspWidth/voxelSize)+(fingerThickness/voxelSize)));
                botFingerPix = [botFingerShiftedX(:),botFingerShiftedY(:)];
              
                fingerInd = sub2ind(size(heightmap),botFingerPix(:,2),botFingerPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end
                if medianLocalHeightmap > prctile(heightmap(fingerInd),90) + 0.02
                    [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),20:(20+(graspWidth/voxelSize)));
                    midGraspPix = [midGraspX(:),midGraspY(:)];
                    graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,20,botFingerPix(18*14+1,:)];

                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                    
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0); 
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    

                    break;
                end
            end
        end
    end
    
    for dy = [16,17]
        localHeightMap = heightmap((dy*10-9):(dy*10),(dx*10-9):(dx*10));
        if sum(localHeightMap(:) > 0) > 75
            xCoord = dx*10-5;
            yCoord = dy*10-5;          
            for graspWidth = 0.03:0.02:0.11
                [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180-(graspWidth/voxelSize)):180);
                midGraspPix = [midGraspX(:),midGraspY(:)];
                [topFingerShiftedX,topFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180+1-(graspWidth/voxelSize)-(fingerThickness/voxelSize)):(180-(graspWidth/voxelSize)));
                topFingerPix = [topFingerShiftedX(:),topFingerShiftedY(:)];
                fingerInd = sub2ind(size(heightmap),topFingerPix(:,2),topFingerPix(:,1));
                graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end

                if heightmap(yCoord,xCoord) > prctile(heightmap(fingerInd),90) + 0.02
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,180,topFingerPix(18*15,:)];
                    
                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                  
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0);
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    
                    
                    break; 
                end
            end
        end
    end
end

end
            for graspWidth = 0.03:0.02:0.11
                [botFingerShiftedX,botFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(21+(graspWidth/voxelSize)):(20+(graspWidth/voxelSize)+(fingerThickness/voxelSize)));
                botFingerPix = [botFingerShiftedX(:),botFingerShiftedY(:)];
              
                fingerInd = sub2ind(size(heightmap),botFingerPix(:,2),botFingerPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end
                if medianLocalHeightmap > prctile(heightmap(fingerInd),90) + 0.02
                    [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),20:(20+(graspWidth/voxelSize)));
                    midGraspPix = [midGraspX(:),midGraspY(:)];
                    graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,20,botFingerPix(18*14+1,:)];

                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                    
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0); 
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    

                    break;
                end
            end
        end
    end
    
    for dy = [16,17]
        localHeightMap = heightmap((dy*10-9):(dy*10),(dx*10-9):(dx*10));
        if sum(localHeightMap(:) > 0) > 75
            xCoord = dx*10-5;
            yCoord = dy*10-5;          
            for graspWidth = 0.03:0.02:0.11
                [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180-(graspWidth/voxelSize)):180);
                midGraspPix = [midGraspX(:),midGraspY(:)];
                [topFingerShiftedX,topFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180+1-(graspWidth/voxelSize)-(fingerThickness/voxelSize)):(180-(graspWidth/voxelSize)));
                topFingerPix = [topFingerShiftedX(:),topFingerShiftedY(:)];
                fingerInd = sub2ind(size(heightmap),topFingerPix(:,2),topFingerPix(:,1));
                graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end

                if heightmap(yCoord,xCoord) > prctile(heightmap(fingerInd),90) + 0.02
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,180,topFingerPix(18*15,:)];
                    
                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                  
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0);
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    
                    
                    break; 
                end
            end
        end
    end
end

end            for graspWidth = 0.03:0.02:0.11
                [botFingerShiftedX,botFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(21+(graspWidth/voxelSize)):(20+(graspWidth/voxelSize)+(fingerThickness/voxelSize)));
                botFingerPix = [botFingerShiftedX(:),botFingerShiftedY(:)];
              
                fingerInd = sub2ind(size(heightmap),botFingerPix(:,2),botFingerPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end
                if medianLocalHeightmap > prctile(heightmap(fingerInd),90) + 0.02
                    [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),20:(20+(graspWidth/voxelSize)));
                    midGraspPix = [midGraspX(:),midGraspY(:)];
                    graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,20,botFingerPix(18*14+1,:)];

                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                    
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0); 
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    

                    break;
                end
            end
        end
    end
    
    for dy = [16,17]
        localHeightMap = heightmap((dy*10-9):(dy*10),(dx*10-9):(dx*10));
        if sum(localHeightMap(:) > 0) > 75
            xCoord = dx*10-5;
            yCoord = dy*10-5;          
            for graspWidth = 0.03:0.02:0.11
                [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180-(graspWidth/voxelSize)):180);
                midGraspPix = [midGraspX(:),midGraspY(:)];
                [topFingerShiftedX,topFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180+1-(graspWidth/voxelSize)-(fingerThickness/voxelSize)):(180-(graspWidth/voxelSize)));
                topFingerPix = [topFingerShiftedX(:),topFingerShiftedY(:)];
                fingerInd = sub2ind(size(heightmap),topFingerPix(:,2),topFingerPix(:,1));
                graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end

                if heightmap(yCoord,xCoord) > prctile(heightmap(fingerInd),90) + 0.02
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,180,topFingerPix(18*15,:)];
                    
                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                  
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0);
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    
                    
                    break; 
                end
            end
        end
    end
end

end            for graspWidth = 0.03:0.02:0.11
                [botFingerShiftedX,botFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(21+(graspWidth/voxelSize)):(20+(graspWidth/voxelSize)+(fingerThickness/voxelSize)));
                botFingerPix = [botFingerShiftedX(:),botFingerShiftedY(:)];
              
                fingerInd = sub2ind(size(heightmap),botFingerPix(:,2),botFingerPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end
                if medianLocalHeightmap > prctile(heightmap(fingerInd),90) + 0.02
                    [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),20:(20+(graspWidth/voxelSize)));
                    midGraspPix = [midGraspX(:),midGraspY(:)];
                    graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,20,botFingerPix(18*14+1,:)];

                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                    
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0); 
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    

                    break;
                end
            end
        end
    end
    
    for dy = [16,17]
        localHeightMap = heightmap((dy*10-9):(dy*10),(dx*10-9):(dx*10));
        if sum(localHeightMap(:) > 0) > 75
            xCoord = dx*10-5;
            yCoord = dy*10-5;          
            for graspWidth = 0.03:0.02:0.11
                [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180-(graspWidth/voxelSize)):180);
                midGraspPix = [midGraspX(:),midGraspY(:)];
                [topFingerShiftedX,topFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180+1-(graspWidth/voxelSize)-(fingerThickness/voxelSize)):(180-(graspWidth/voxelSize)));
                topFingerPix = [topFingerShiftedX(:),topFingerShiftedY(:)];
                fingerInd = sub2ind(size(heightmap),topFingerPix(:,2),topFingerPix(:,1));
                graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end

                if heightmap(yCoord,xCoord) > prctile(heightmap(fingerInd),90) + 0.02
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,180,topFingerPix(18*15,:)];
                    
                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                  
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0);
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    
                    
                    break; 
                end
            end
        end
    end
end

end            for graspWidth = 0.03:0.02:0.11
                [botFingerShiftedX,botFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(21+(graspWidth/voxelSize)):(20+(graspWidth/voxelSize)+(fingerThickness/voxelSize)));
                botFingerPix = [botFingerShiftedX(:),botFingerShiftedY(:)];
              
                fingerInd = sub2ind(size(heightmap),botFingerPix(:,2),botFingerPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end
                if medianLocalHeightmap > prctile(heightmap(fingerInd),90) + 0.02
                    [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),20:(20+(graspWidth/voxelSize)));
                    midGraspPix = [midGraspX(:),midGraspY(:)];
                    graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,20,botFingerPix(18*14+1,:)];

                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                    
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0); 
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    

                    break;
                end
            end
        end
    end
    
    for dy = [16,17]
        localHeightMap = heightmap((dy*10-9):(dy*10),(dx*10-9):(dx*10));
        if sum(localHeightMap(:) > 0) > 75
            xCoord = dx*10-5;
            yCoord = dy*10-5;          
            for graspWidth = 0.03:0.02:0.11
                [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180-(graspWidth/voxelSize)):180);
                midGraspPix = [midGraspX(:),midGraspY(:)];
                [topFingerShiftedX,topFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180+1-(graspWidth/voxelSize)-(fingerThickness/voxelSize)):(180-(graspWidth/voxelSize)));
                topFingerPix = [topFingerShiftedX(:),topFingerShiftedY(:)];
                fingerInd = sub2ind(size(heightmap),topFingerPix(:,2),topFingerPix(:,1));
                graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end

                if heightmap(yCoord,xCoord) > prctile(heightmap(fingerInd),90) + 0.02
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,180,topFingerPix(18*15,:)];
                    
                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                  
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0);
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    
                    
                    break; 
                end
            end
        end
    end
end

end            for graspWidth = 0.03:0.02:0.11
                [botFingerShiftedX,botFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(21+(graspWidth/voxelSize)):(20+(graspWidth/voxelSize)+(fingerThickness/voxelSize)));
                botFingerPix = [botFingerShiftedX(:),botFingerShiftedY(:)];
              
                fingerInd = sub2ind(size(heightmap),botFingerPix(:,2),botFingerPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end
                if medianLocalHeightmap > prctile(heightmap(fingerInd),90) + 0.02
                    [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),20:(20+(graspWidth/voxelSize)));
                    midGraspPix = [midGraspX(:),midGraspY(:)];
                    graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,20,botFingerPix(18*14+1,:)];

                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                    
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0); 
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    

                    break;
                end
            end
        end
    end
    
    for dy = [16,17]
        localHeightMap = heightmap((dy*10-9):(dy*10),(dx*10-9):(dx*10));
        if sum(localHeightMap(:) > 0) > 75
            xCoord = dx*10-5;
            yCoord = dy*10-5;          
            for graspWidth = 0.03:0.02:0.11
                [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180-(graspWidth/voxelSize)):180);
                midGraspPix = [midGraspX(:),midGraspY(:)];
                [topFingerShiftedX,topFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180+1-(graspWidth/voxelSize)-(fingerThickness/voxelSize)):(180-(graspWidth/voxelSize)));
                topFingerPix = [topFingerShiftedX(:),topFingerShiftedY(:)];
                fingerInd = sub2ind(size(heightmap),topFingerPix(:,2),topFingerPix(:,1));
                graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end

                if heightmap(yCoord,xCoord) > prctile(heightmap(fingerInd),90) + 0.02
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,180,topFingerPix(18*15,:)];
                    
                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                  
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0);
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    
                    
                    break; 
                end
            end
        end
    end
end

end            for graspWidth = 0.08:0.06:0.11
                [botFingerShiftedX,botFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(21+(graspWidth/voxelSize)):(20+(graspWidth/voxelSize)+(fingerThickness/voxelSize)));
                botFingerPix = [botFingerShiftedX(:),botFingerShiftedY(:)];
              
                fingerInd = sub2ind(size(heightmap),botFingerPix(:,2),botFingerPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end
                if medianLocalHeightmap > prctile(heightmap(fingerInd),90) + 0.02
                    [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),20:(20+(graspWidth/voxelSize)));
                    midGraspPix = [midGraspX(:),midGraspY(:)];
                    graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,20,botFingerPix(18*14+1,:)];

                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                    
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0); 
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    

                    break;
                end
            end
        end
    end
    
    for dy = [16,17]
        localHeightMap = heightmap((dy*10-9):(dy*10),(dx*10-9):(dx*10));
        if sum(localHeightMap(:) > 0) > 75
            xCoord = dx*10-5;
            yCoord = dy*10-5;          
            for graspWidth = 0.03:0.02:0.11
                [midGraspX,midGraspY] = meshgrid((xCoord-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180-(graspWidth/voxelSize)):180);
                midGraspPix = [midGraspX(:),midGraspY(:)];
                [topFingerShiftedX,topFingerShiftedY] = meshgrid((xCoord+1-fingerWidth/(voxelSize*2)):(xCoord+fingerWidth/(voxelSize*2)),(180+1-(graspWidth/voxelSize)-(fingerThickness/voxelSize)):(180-(graspWidth/voxelSize)));
                topFingerPix = [topFingerShiftedX(:),topFingerShiftedY(:)];
                fingerInd = sub2ind(size(heightmap),topFingerPix(:,2),topFingerPix(:,1));
                graspInd = sub2ind(size(heightmap),midGraspPix(:,2),midGraspPix(:,1));

                if min(fingerInd) < 0 || max(fingerInd) > length(heightmap(:))
                    continue;
                end

                if heightmap(yCoord,xCoord) > prctile(heightmap(fingerInd),90) + 0.02
                    surfacePts = heightmap(graspInd) > median(heightmap(fingerInd));
                    graspConf = max((sum(surfacePts(:))./size(graspInd,1)),0);
                    graspPtsPix = [xCoord,180,topFingerPix(18*15,:)];
                    
                    colorMapJet = jet;
                    colorScale = colorMapJet(floor(graspConf.*63)+1,:);
                    hold on; plot([graspPtsPix(1);graspPtsPix(3)],[graspPtsPix(2);graspPtsPix(4)],'LineWidth',2,'Color',colorScale);
                  
                    graspCenterPix = mean([graspPtsPix(1:2);graspPtsPix(3:4)]);
                    graspDirection = (graspPtsPix(1:2)-graspPtsPix(3:4))./norm((graspPtsPix(1:2)-graspPtsPix(3:4)));
                    diffAngle = atan2d(graspDirection(1)*0-graspDirection(2)*1,graspDirection(1)*1+graspDirection(2)*0);
                    while diffAngle < 0
                        diffAngle = diffAngle+360;
                    end
                    rotIdx = mod(round(diffAngle/(45/2)),8); 
                    flushGraspPredictions = [flushGraspPredictions;[graspCenterPix,rotIdx,graspConf]];
                    
                    
                    break; 
                end
            end
        end
    end
end

end