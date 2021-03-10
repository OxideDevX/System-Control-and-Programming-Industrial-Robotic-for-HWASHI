
snapshotsFolder = 'snapshots-with-class';  % which model?
testImgsLabels = dlmread('data/test-labels.txt');
prodImgLabel = sort(dlmread('data/test-product-labels.txt'));
testOtherObjList = dlmread('data/test-other-objects-list.txt');

trainImgPath = 'data/train-imgs';
trainImgList = dir(trainImgPath);
trainImgList = trainImgList(3:end);
trainClasses = {};
for objIdx = 1:length(trainImgList)
    trainClasses{length(trainClasses)+1} = lower(trainImgList(objIdx).name);
end
testImgPath = 'data/test-item-data';
testImgList = dir(testImgPath);
testImgList = testImgList(3:end);
testClasses = {};
for objIdx = 1:length(testImgList)
    testClasses{length(testClasses)+1} = lower(testImgList(objIdx).name);
end

for snapshotIdx = 20 %по заводу 17
    snapshotName = sprintf('snapshot-%d',snapshotIdx*10000);

    resultsFile = fullfile(snapshotsFolder,sprintf('results-%s.h5',snapshotName));
    prodImgsFeats = hdf5read(resultsFile,'prodFeat');
    prodImgsFeats = prodImgsFeats';
    testImgsFeats = hdf5read(resultsFile,'testFeat');
    testImgsFeats = testImgsFeats';

    prodIsKnownObj = zeros(size(prodImgsFeats,1),1);
    testIsKnownObj = zeros(size(testImgsFeats,1),1);
    for objIdx = 1:length(testClasses)
         trainClassIdx = cellfun(@(x) strcmp(testClasses{objIdx},x),trainClasses);
         if any(trainClassIdx)
             prodIsKnownObj(find(prodImgLabel == objIdx)) = 1;
             testIsKnownObj(find(testImgsLabels == objIdx)) = 1;
         end
    end

    predLabels = zeros(size(testImgsLabels,1),5);
    predNnDist = zeros(size(testImgsLabels));
    for testImgIdx = 1:size(testImgsFeats,1)
        testImgFeat = testImgsFeats(testImgIdx,:);
        featDists = sqrt(sum((repmat(testImgFeat,size(prodImgsFeats,1),1)-prodImgsFeats).^2,2));
        featDists = [prodImgLabel,featDists];
        validProdImgInd = arrayfun(@(x) any(testOtherObjList(testImgIdx,:) == x),prodImgLabel);
        sortedFeatDists = sortrows(featDists(find(validProdImgInd),:),2);
        predNnDist(testImgIdx) = min(sortedFeatDists(:,2));
        sortedClassPred = sortedFeatDists(:,1);
        predLabels(testImgIdx,:) = sortedClassPred(1:5)';
    end
    
    bestKnownNovelAcc = 0;
    for threshold = 0:0.01:1.2
        knownNovelAcc = sum((predNnDist > threshold) == ~testIsKnownObj)/length(testIsKnownObj);
        bestKnownNovelAcc = max(bestKnownNovelAcc,knownNovelAcc);
    end
    
    oldObjImgIdx = find(testIsKnownObj);
    newObjImgIdx = find(~testIsKnownObj);
    oldObjAcc = sum(testImgsLabels(oldObjImgIdx) == predLabels(oldObjImgIdx,1))/length(oldObjImgIdx);
    newObjAcc = sum(testImgsLabels(newObjImgIdx) == predLabels(newObjImgIdx,1))/length(newObjImgIdx);
    avgObjAcc = sum(testImgsLabels == predLabels(:,1),1)/length(testImgsLabels);
    fprintf('Model: %s\n  Old object accuracy: %f\n  Novel object accuracy: %f\n  Mixed object accuracy: %f\n  Known vs novel classification accuracy: %f\n',snapshotName,oldObjAcc,newObjAcc,avgObjAcc,bestKnownNovelAcc);
end