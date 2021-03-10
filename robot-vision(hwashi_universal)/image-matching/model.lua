require 'image'
require 'cutorch'
require 'cunn'
require 'cudnn'


function getColorClassMultiProdSkipConnModel(numObjClasses,numTypeClasses)

    -- Load 2 ResNet-101 pre-trained on ImageNet as RGB-D tower
    local rgbTrunk = torch.load('resnet-50.t7')
    rgbTrunk:remove(11)
    rgbTrunk:insert(nn.Normalize(2))

    local tripletTrunk = nn.ParallelTable()
    local prodImgTower = nn.Sequential():add(nn.Identity)
    local toteImgTower = rgbTrunk:clone()
    tripletTrunk:add(toteImgTower) 
    tripletTrunk:add(prodImgTower)
    tripletTrunk:add(toteImgTower:clone('weight','bias','gradWeight','gradBias')) 

    local classifyObjJoint = nn.Sequential():add(nn.SelectTable(1))
    classifyObjJoint:add(nn.Linear(2048,512)):add(nn.BatchNormalization(512)):add(nn.ReLU()):add(nn.Dropout(0.5))
    classifyObjJoint:add(nn.Linear(512,128)):add(nn.BatchNormalization(128)):add(nn.ReLU()):add(nn.Dropout(0.5))
    classifyObjJoint:add(nn.Linear(128,numObjClasses))

    local classifyTypeJoint = nn.Sequential():add(nn.SelectTable(1))
    classifyTypeJoint:add(nn.Linear(2048,512)):add(nn.BatchNormalization(512)):add(nn.ReLU()):add(nn.Dropout(0.5))
    classifyTypeJoint:add(nn.Linear(512,128)):add(nn.BatchNormalization(128)):add(nn.ReLU()):add(nn.Dropout(0.5))
    classifyTypeJoint:add(nn.Linear(128,numTypeClasses))

    local posDistJoint = nn.Sequential() 
    posDistJoint:add(nn.NarrowTable(1,2)):add(nn.PairwiseDistance(2))
    local negDistJoint = nn.Sequential()
    negDistJoint:add(nn.NarrowTable(2,2)):add(nn.PairwiseDistance(2))
    local distJoint = nn.ConcatTable():add(posDistJoint):add(negDistJoint):add(classifyObjJoint):add(classifyTypeJoint)

    local model = nn.Sequential()
    model:add(tripletTrunk)
    model:add(distJoint)

    local criterionDist = nn.DistanceRatioCriterion(true):cuda()

    local criterionClass = nn.CrossEntropyCriterion():cuda()

    local criterionType = nn.CrossEntropyCriterion():cuda()

    return model,criterionDist,criterionClass,criterionType
end

function getColorClassMultiProdModel(numClasses)

    local rgbTrunk = torch.load('resnet-50.t7')
    rgbTrunk:remove(11)
    rgbTrunk:insert(nn.Normalize(2))

    local tripletTrunk = nn.ParallelTable()
    local prodImgTower = nn.Sequential():add(nn.Identity)
    local toteImgTower = rgbTrunk:clone()
    tripletTrunk:add(toteImgTower) 
    tripletTrunk:add(prodImgTower)
    tripletTrunk:add(toteImgTower:clone('weight','bias','gradWeight','gradBias')) 

    local classifyJoint = nn.Sequential():add(nn.SelectTable(1))
    classifyJoint:add(nn.Linear(2048,512)):add(nn.BatchNormalization(512)):add(nn.ReLU()):add(nn.Dropout(0.5))
    classifyJoint:add(nn.Linear(512,128)):add(nn.BatchNormalization(128)):add(nn.ReLU()):add(nn.Dropout(0.5))
    classifyJoint:add(nn.Linear(128,numClasses))

    local posDistJoint = nn.Sequential() 
    posDistJoint:add(nn.NarrowTable(1,2)):add(nn.PairwiseDistance(2))
    local negDistJoint = nn.Sequential() 
    negDistJoint:add(nn.NarrowTable(2,2)):add(nn.PairwiseDistance(2))
    local distJoint = nn.ConcatTable():add(posDistJoint):add(negDistJoint):add(classifyJoint)
    local model = nn.Sequential()
    model:add(tripletTrunk)
    model:add(distJoint)
    local criterionDist = nn.DistanceRatioCriterion(true):cuda()
    local criterionClass = nn.CrossEntropyCriterion():cuda()
    return model,criterionDist,criterionClass
end

function getColorNoClassFullProdModel(isSharedWeights)

    local rgbTrunk = torch.load('resnet-50.t7')
    rgbTrunk:remove(11)
    rgbTrunk:insert(nn.Normalize(2))

    local tripletTrunk = nn.ParallelTable()
    local prodImgTower = rgbTrunk:clone()
    local toteImgTower = rgbTrunk:clone()
    tripletTrunk:add(toteImgTower) 
    if isSharedWeights then
        tripletTrunk:add(toteImgTower:clone('weight','bias','gradWeight','gradBias')) 
    else
        tripletTrunk:add(prodImgTower)
    end
    tripletTrunk:add(toteImgTower:clone('weight','bias','gradWeight','gradBias')) 

    local posDistJoint = nn.Sequential() 
    posDistJoint:add(nn.NarrowTable(1,2)):add(nn.PairwiseDistance(2))
    local negDistJoint = nn.Sequential() 
    negDistJoint:add(nn.NarrowTable(2,2)):add(nn.PairwiseDistance(2))
    local distJoint = nn.ConcatTable():add(posDistJoint):add(negDistJoint)


    local model = nn.Sequential()
    model:add(tripletTrunk)
    model:add(distJoint)

    local criterionDist = nn.DistanceRatioCriterion(true):cuda()

    return model,criterionDist
end

function getColorNoClassMultiProdModel()

    local rgbTrunk = torch.load('resnet-50.t7')
    rgbTrunk:remove(11)
    rgbTrunk:insert(nn.Normalize(2))

    local tripletTrunk = nn.ParallelTable()
    local prodImgTower = nn.Sequential():add(nn.Identity)
    local toteImgTower = rgbTrunk:clone()
    tripletTrunk:add(toteImgTower) 
    tripletTrunk:add(prodImgTower)
    tripletTrunk:add(toteImgTower:clone('weight','bias','gradWeight','gradBias')) 

    local posDistJoint = nn.Sequential() 
    posDistJoint:add(nn.NarrowTable(1,2)):add(nn.PairwiseDistance(2))
    local negDistJoint = nn.Sequential() 
    negDistJoint:add(nn.NarrowTable(2,2)):add(nn.PairwiseDistance(2))
    local distJoint = nn.ConcatTable():add(posDistJoint):add(negDistJoint)

    local model = nn.Sequential()
    model:add(tripletTrunk)
    model:add(distJoint)

    local criterionDist = nn.DistanceRatioCriterion(true):cuda()

    return model,criterionDist
end

function getColorClassModel()

    local rgbTrunk = torch.load('resnet-50.t7')
    rgbTrunk:remove(11)
    rgbTrunk:insert(nn.Normalize(2))

    local tripletTrunk = nn.ParallelTable()
    local prodImgTower = rgbTrunk:clone()
    local toteImgTower = rgbTrunk:clone()
    tripletTrunk:add(toteImgTower) 
    recursiveModelFreeze(prodImgTower)
    tripletTrunk:add(prodImgTower)
    tripletTrunk:add(toteImgTower:clone('weight','bias','gradWeight','gradBias')) 


    local classifyJoint = nn.Sequential():add(nn.SelectTable(1))
    classifyJoint:add(nn.Linear(2048,512)):add(nn.BatchNormalization(512)):add(nn.ReLU()):add(nn.Dropout(0.5))
    classifyJoint:add(nn.Linear(512,128)):add(nn.BatchNormalization(128)):add(nn.ReLU()):add(nn.Dropout(0.5))
    classifyJoint:add(nn.Linear(128,30))

    local posDistJoint = nn.Sequential() 
    posDistJoint:add(nn.NarrowTable(1,2)):add(nn.PairwiseDistance(2))
    local negDistJoint = nn.Sequential()
    negDistJoint:add(nn.NarrowTable(2,2)):add(nn.PairwiseDistance(2))
    local distJoint = nn.ConcatTable():add(posDistJoint):add(negDistJoint):add(classifyJoint)

    local model = nn.Sequential()
    model:add(tripletTrunk)
    model:add(distJoint)

    local criterionDist = nn.DistanceRatioCriterion(true):cuda()

    local criterionClass = nn.CrossEntropyCriterion():cuda()

    return model,criterionDist,criterionClass
end

function getRGBDModel()

    local rgbTrunk = torch.load('resnet-50.t7')
    rgbTrunk:remove(11)
    rgbTrunk:insert(nn.Normalize(2))
    local dTrunk = rgbTrunk:clone()
    local rgbdParallel = nn.ParallelTable():add(rgbTrunk):add(dTrunk)
    local rgbdTrunk = nn.Sequential():add(rgbdParallel):add(nn.JoinTable(2))
    rgbdTrunk:add(nn.Linear(4096,2048)):add(nn.Normalize(2))
    local tripletTrunk = nn.ParallelTable()
    local prodImgTower = rgbTrunk:clone()
    local toteImgTower = rgbdTrunk:clone()
    tripletTrunk:add(toteImgTower) 
    recursiveModelFreeze(prodImgTower)
    tripletTrunk:add(prodImgTower)
    tripletTrunk:add(toteImgTower:clone('weight','bias','gradWeight','gradBias')) 

end