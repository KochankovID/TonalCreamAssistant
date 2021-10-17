import cv2
import numpy as np
from matplotlib import pyplot as plt

from sklearn.cluster import KMeans


def palette(clusters):
    width = 300
    palette = np.zeros((50, width, 3), np.uint8)
    steps = width / clusters.cluster_centers_.shape[0]
    for idx, centers in enumerate(clusters.cluster_centers_):
        palette[:, int(idx * steps):(int((idx + 1) * steps)), :] = centers
    return palette


def show_img_compar(img_1, img_2):
    f, ax = plt.subplots(1, 2, figsize=(10, 10))
    ax[0].imshow(cv2.cvtColor(img_1, cv2.COLOR_BGR2RGB))
    ax[1].imshow(cv2.cvtColor(img_2, cv2.COLOR_BGR2RGB))
    ax[0].axis('off')  # hide the axis
    ax[1].axis('off')
    f.tight_layout()
    plt.show()


if __name__ == '__main__':
    face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
    img = cv2.imread('test_img/w_sexy.jpeg')
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    face = face_cascade.detectMultiScale(gray, 1.1, 4)[0]
    face_img = img[face[1]:face[1] + face[3], face[0]:face[0] + face[2], :]
    print(face_img)

    k_means = KMeans(n_clusters=1)
    k_means.fit(face_img.reshape(face_img.shape[0] * face_img.shape[1], 3))
    print(k_means.cluster_centers_)

    show_img_compar(img, palette(k_means))
