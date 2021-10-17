import cv2
from argparse import ArgumentParser

def findFace(img):
	# Use Haar cascades for face detection
	# (opencv/build/etc/haarcascades)
	face_cascade_db = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
	
	# Detect face
	face = face_cascade_db.detectMultiScale(img, 1.1, 19)
	
	# Square face (Only for demo)
	for (x,y,w,h) in face:
		cv2.rectangle(img, (x,y), (x+w,y+h), (0,255,0), 2)

	cv2.imwrite('face2_n.jpg', img)
	
	cv2.imshow('face', img)
	cv2.waitKey()

# Arguments
arguments_parser = ArgumentParser()
arguments_parser.add_argument('-p', '--photo', help='Photo of the face')

args = arguments_parser.parse_args()

src_img = cv2.imread(args.photo, cv2.IMREAD_COLOR)
cv2.imshow('photo', src_img)
cv2.waitKey()

# Find the face
findFace(src_img)
