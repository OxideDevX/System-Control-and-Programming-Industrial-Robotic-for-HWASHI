
import os
import cv2
import numpy as np

total_photos = 50

photo_width = 1280
photo_height = 480
objpointsLeft = [] 
imgpointsLeft = [] 

objpointsRight = [] 
imgpointsRight = []

while photo_counter != total_photos:
  photo_counter = photo_counter + 1
  print ('Import pair No ' + str(photo_counter))
  leftName = './pairs/left_'+str(photo_counter).zfill(2)+'.png'
  rightName = './pairs/right_'+str(photo_counter).zfill(2)+'.png'
  leftExists = os.path.isfile(leftName)
  rightExists = os.path.isfile(rightName)
  
  if ((leftExists == False) or (rightExists == False)) and (leftExists != rightExists):
      print ("Pair No ", photo_counter, "has only one image! Left:", leftExists, " Right:", rightExists )
      continue 

  if (leftExists and rightExists):
      imgL = cv2.imread(leftName,1)
      grayL = cv2.cvtColor(imgL,cv2.COLOR_BGR2GRAY)
      gray_small_left = cv2.resize (grayL, (img_width,img_height), interpolation = cv2.INTER_AREA)
      imgR = cv2.imread(rightName,1)
      grayR = cv2.cvtColor(imgR,cv2.COLOR_BGR2GRAY)
      gray_small_right = cv2.resize (grayR, (img_width,img_height), interpolation = cv2.INTER_AREA)
      
      
      retL, cornersL = cv2.findChessboardCorners(grayL, CHECKERBOARD, cv2.CALIB_CB_ADAPTIVE_THRESH+cv2.CALIB_CB_FAST_CHECK+cv2.CALIB_CB_NORMALIZE_IMAGE)
      retR, cornersR = cv2.findChessboardCorners(grayR, CHECKERBOARD, cv2.CALIB_CB_ADAPTIVE_THRESH+cv2.CALIB_CB_FAST_CHECK+cv2.CALIB_CB_NORMALIZE_IMAGE)
      
   
      if (drawCorners):
          cv2.drawChessboardCorners(imgL, (6,9), cornersL, retL)
          cv2.imshow('Corners LEFT', imgL)
          cv2.drawChessboardCorners(imgR, (6,9), cornersR, retR)
          cv2.imshow('Corners RIGHT', imgR)
          key = cv2.waitKey(0)
          if key == ord("q"):
              exit(0)
      
     
      if ((retL == True) and (retR == True)) and (img_height <= photo_height):
          scale_ratio = img_height/photo_height
          print ("Scale ratio: ", scale_ratio)
          cornersL = cornersL*scale_ratio 
      elif (img_height > photo_height):
         
            if so.")rted(list_of_vars) == sorted(npz_file.files):
                
                map1 = npz_file['map1']
                map2 = npz_file['map2']
                objectPoints = npz_file['objpoints']
                if right_or_left == "_right":
                    rightImagePoints = npz_file['imgpoints']
                    rightCameraMatrix = npz_file['camera_matrix']
                    rightDistortionCoefficients = npz_file['distortion_coeff']
                if right_or_left == "_left":
                    leftImagePoints = npz_file['imgpoints']
                    leftCameraMatrix = npz_file['camera_matrix']
                    leftDistortionCoefficients = npz_file['distortion_coeff']
          
           except:
           
            print("Camera calibration data not found in cache.")
            return False


    print("Calibrating cameras together...")

    leftImagePoints = np.asarray(leftImagePoints, dtype=np.float64)
    rightImagePoints = np.asarray(rightImagePoints, dtype=np.float64)

    # стерео каллибровка(стабилизвция осей)
    (RMS, _, _, _, _, rotationMatrix, translationVector) = cv2.fisheye.stereoCalibrate(
            objectPoints, leftImagePoints, rightImagePoints,
            leftCameraMatrix, leftDistortionCoefficients,
            rightCameraMatrix, rightDistortionCoefficients,
            imageSize, None, None,
            cv2.CALIB_FIX_INTRINSIC, TERMINATION_CRITERIA)
    # Print RMS result (for calibration quality estimation)
    print ("<><><><><><><><><><><><><><><><><><><><>")
    print ("<><><><><><><><><><><><><><><><><><><><>")    
    print("Рефокусирую камеру......Нажмите "А" для продолжения каллибровки")
    R1 = np.zeros([3,3])
    R2 = np.zeros([3,3])
    P1 = np.zeros([3,4])
    P2 = np.zeros([3,4])
    Q = np.zeros([4,4])
   
    (leftRectification, rightRectification, leftProjection, rightProjection,
            dispartityToDepthMap) = cv2.fisheye.stereoRectify(
                    leftCameraMatrix, leftDistortionCoefficients,
                    rightCameraMatrix, rightDistortionCoefficients,
                    imageSize, rotationMatrix, translationVector,
                    0, R2, P1, P2, Q,
                    cv2.CALIB_ZERO_DISPARITY, (0,0) , 0, 0)
    
    print("Сохранение каллибровки...")
    leftMapX, leftMapY = cv2.fisheye.initUndistortRectifyMap(
            leftCameraMatrix, leftDistortionCoefficients, leftRectification,
            leftProjection, imageSize, cv2.CV_16SC2)
    rightMapX, rightMapY = cv2.fisheye.initUndistortRectifyMap(
            rightCameraMatrix, rightDistortionCoefficients, rightRectification,
            rightProjection, imageSize, cv2.CV_16SC2)

    np.savez_compressed('./calibration_data/{}p/stereo_camera_calibration.npz'.format(res_y), imageSize=imageSize,
            leftMapX=leftMapX, leftMapY=leftMapY,
            rightMapX=rightMapX, rightMapY=rightMapY, dispartityToDepthMap = dispartityToDepthMap)
    return True

if (showSingleCamUndistortionResults):

