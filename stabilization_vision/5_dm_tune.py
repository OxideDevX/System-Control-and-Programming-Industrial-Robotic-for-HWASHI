
import cv2
import os
from picamera.array import PiRGBArray
from picamera import PiCamera
from matplotlib import pyplot as plt
from matplotlib.widgets import Slider, Button
import numpy as np
import json
import time

imageToDisp = './scenes/dm-tune.jpg'
photo_width = 750
photo_height = 255
image_width = 380
image_height = 140

image_size = (image_width,image_height)

if os.path.isfile(imageToDisp) == False:
    camera = PiCamera(stereo_mode='side-by-side',stereo_decimate=False)
    camera.resolution=(photo_width, photo_height)
      camera.capture(imageToDisp)

pair_img = cv2.imread(imageToDisp,0)
# Read image and split it in a stereo pair
print('Read and split image...')
imgLeft = pair_img [0:photo_height,0:image_width] #Y+H and X+W
imgRight = pair_img [0:photo_height,image_width:photo_width] #Y+H and X+W

# Implementing calibration data
print('Read calibration data and rectifying stereo pair...')

try:
    npzfile = np.load('./calibration_data/{}p/stereo_camera_calibration.npz'.format(image_height))
except:
    print("Camera calibration data not found in cache, file " & './calibration_data/{}p/stereo_camera_calibration.npz'.format(480))
    exit(0)
    
imageSize = tuple(npzfile['imageSize'])
leftMapX = npzfile['leftMapX']
leftMapY = npzfile['leftMapY']
rightMapX = npzfile['rightMapX']
rightMapY = npzfile['rightMapY']

width_left, height_left = imgLeft.shape[:2]
width_right, height_right = imgRight.shape[:2]

SWSaxe = plt.axes([0.15, 0.01, 0.7, 0.025], facecolor=axcolor) 
PFSaxe = plt.axes([0.15, 0.05, 0.7, 0.025], facecolor=axcolor) 
PFCaxe = plt.axes([0.15, 0.09, 0.7, 0.025], facecolor=axcolor) 
MDSaxe = plt.axes([0.15, 0.13, 0.7, 0.025], facecolor=axcolor) 
NODaxe = plt.axes([0.15, 0.17, 0.7, 0.025], facecolor=axcolor)  
TTHaxe = plt.axes([0.15, 0.21, 0.7, 0.025], facecolor=axcolor)  
URaxe = plt.axes([0.15, 0.25, 0.7, 0.025], facecolor=axcolor) 
SRaxe = plt.axes([0.15, 0.29, 0.7, 0.025], facecolor=axcolor) 
SPWSaxe = plt.axes([0.15, 0.33, 0.7, 0.025], facecolor=axcolor) 

sSWS = Slider(SWSaxe, 'SWS', 5.0, 255.0, valinit=5)
sPFS = Slider(PFSaxe, 'PFS', 5.0, 255.0, valinit=5)
sPFC = Slider(PFCaxe, 'PreFiltCap', 5.0, 63.0, valinit=29)
sMDS = Slider(MDSaxe, 'MinDISP', -100.0, 100.0, valinit=-25)
sNOD = Slider(NODaxe, 'NumOfDisp', 16.0, 256.0, valinit=128)
sTTH = Slider(TTHaxe, 'TxtrThrshld', 0.0, 1000.0, valinit=100)
sUR = Slider(URaxe, 'UnicRatio', 1.0, 20.0, valinit=10)
sSR = Slider(SRaxe, 'SpcklRng', 0.0, 40.0, valinit=15)
sSPWS = Slider(SPWSaxe, 'SpklWinSze', 0.0, 300.0, valinit=100)

def update(val):
    global SWS, PFS, PFC, MDS, NOD, TTH, UR, SR, SPWS
    SWS = int(sSWS.val/2)*2+1 
    PFS = int(sPFS.val/2)*2+1
    PFC = int(sPFC.val/2)*2+1    
    MDS = int(sMDS.val)    
    NOD = int(sNOD.val/16)*16  
    TTH = int(sTTH.val)
    UR = int(sUR.val)
    SR = int(sSR.val)
    SPWS= int(sSPWS.val)
    if ( loading_settings==0 ):
        print ('Rebuilding depth map')
        disparity = stereo_depth_map(rectified_pair)
        dmObject.set_data(disparity)
        print ('Redraw depth map')
        plt.draw()

sSWS.on_changed(update)
sPFS.on_changed(update)
sPFC.on_changed(update)
sMDS.on_changed(update)
sNOD.on_changed(update)
sTTH.on_changed(update)
sUR.on_changed(update)
sSR.on_changed(update)
sSPWS.on_changed(update)

print('Show interface to user')
plt.show()
