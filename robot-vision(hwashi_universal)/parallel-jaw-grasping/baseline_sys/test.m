
dataPath = '../data';  
testSplit = textread(fullfile(dataPath,'test-split.txt'),'%s','delimiter','\n');
results = cell(length(testSplit),1);
for sampleIdx = 1:length(testSplit)
    fprintf('Testing: %d/%d\n',sampleIdx,length(testSplit));
    sampleName = testSplit{sampleIdx};
    heightmap = imread(fullfile(dataPath,'heightmap-depth',sprintf('%s.png',sampleName)));
    heightmap = double(heightmap)./10000; 
    heightmap = heightmap(13:212,11:310);
    imshow(heightmap);
    [graspPredictions,flushGraspPredictions] = predict(heightmap);
    results{sampleIdx} = [graspPredictions;flushGraspPredictions];
    pause(0.1);
end

save('results.mat','results');













