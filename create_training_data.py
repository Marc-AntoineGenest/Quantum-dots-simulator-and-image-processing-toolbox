import numpy as np
import matplotlib.pyplot as plt

def load_train_data(i, j):
    data = np.loadtxt('../training_data/processed_{}_{}_signal.txt'.format(i,j))
    truth = np.loadtxt('../training_data/processed_{}_{}_trans.txt'.format(i,j))

    return data, truth

def load_test_data(i, j):
    data = np.loadtxt('../test_data/processed_{}_{}_signal.txt'.format(i,j))
    truth = np.loadtxt('../test_data/processed_{}_{}_trans.txt'.format(i,j))

    return data, truth

def coarse_grain(data, truth, pixels):
    grid_data = np.zeros((np.shape(data)[0] // pixels, np.shape(data)[1] // pixels))
    grid_truth = np.zeros((np.shape(truth)[0] // pixels, np.shape(truth)[1] // pixels))
    
    """ Use mean pooling here """
    for i in range(np.shape(grid_data)[0]):
        for j in range(np.shape(grid_data)[1]):
            grid_data[i, j] = np.mean(data[pixels*i:pixels*(i+1), pixels*j:pixels*(j+1)])
    for i in range(np.shape(grid_truth)[0]):
        for j in range(np.shape(grid_truth)[1]):
            grid_truth[i, j] = np.mean(truth[pixels*i:pixels*(i+1), pixels*j:pixels*(j+1)])

    grid_truth = (grid_truth > 0).astype(int)

    return grid_data, grid_truth

def coarse_patch(data, truth, sizex, sizey):
    rx = np.random.randint(np.shape(data)[0] - sizex)
    ry = np.random.randint(np.shape(data)[1] - sizey)

    patch_data = data[rx:rx+sizex, ry:ry+sizey]
    patch_truth = truth[rx:rx+sizex, ry:ry+sizey]

    return patch_data, patch_truth

def create_coarse_data(imax_train, imax_test, jmax, reps, pixels, patchx, patchy, ratio):
    counter = 0
    for i in range(1,imax_train+1):
        for j in range(1,jmax+1):
            data_train, truth_train = load_train_data(i,j)
            d, t = coarse_grain(data_train, truth_train, pixels)
            for k in range(reps):
                patch_d, patch_t = coarse_patch(d, t, patchx, patchy)
                true_val = (np.mean(patch_t) >= ratio).astype(int)

                with open('Coarse_Train/coarse_{}_data.txt'.format(counter), 'wb') as f:
                    np.save(f, patch_d)
                with open('Coarse_Train/coarse_{}_truth.txt'.format(counter), 'wb') as f:
                    np.save(f, true_val)
                counter += 1

    counter = 0
    for i in range(1, imax_test+1):
        for j in range(1, jmax+1):
            data_test, truth_test = load_test_data(i,j)
            d, t = coarse_grain(data_test, truth_test, pixels)
            for k in range(reps):
                path_d, patch_t = coarse_patch(d, t, patchx, patchy)
                true_val = (np.mean(patch_t) >= ratio).astype(int)

                with open('Coarse_Test/coarse_{}_data.txt'.format(counter), 'wb') as f:
                    np.save(f, patch_d)
                with open('Coarse_Test/coarse_{}_truth.txt'.format(counter), 'wb') as f:
                    np.save(f, true_val)
                counter += 1


""" 
imax and jmax correspond to the numbers in the file names created by matlab
imax states the number of ideal diagrams created
jmax states the number of noise combinations added to each ideal diagram
reps states how many patches are created per diagram
pixels states the number of pixels used for coarsening
patchx and patchy state the patch size patchx x patchy
ratio defines when the ground truth is declared as True
"""
imax_train = 28
imax_test = 7
jmax = 20
reps = 10
pixels = 5
patchx = 4
patchy = 8
ratio = 0.2
create_coarse_data(imax_train, imax_test, jmax, reps, pixels, patchx, patchy, ratio)
