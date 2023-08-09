import random
from torch.utils.data import TensorDataset, random_split
from torch.nn.functional import normalize
from functions import *

#region <Define Directories>
#from torch_geometric_temporal.nn.recurrent import DCRNN

proj_dir = '/content/drive/MyDrive/3_Research_Related/ADHD_Research_Google_Colab'
proj_dir = '/Users/yongjunlee/Library/CloudStorage/GoogleDrive-yongjun.lee5@gmail.com/My Drive/3_Research_Related/ADHD_Research_Google_Colab'
# for GNN models with mutual information adj matrix
mi_dir_adhd   = proj_dir + '/DATA/MI_TABLE/mi_adhd.npy'
mi_dir_control   = proj_dir + '/DATA/MI_TABLE/mi_control.npy'

# for GNN models with correlation adj matrix
corr_dir_adhd   = proj_dir + '/DATA/CORR_TABLE/corr_adhd.npy'
corr_dir_control   = proj_dir + '/DATA/CORR_TABLE/corr_control.npy'

# for CNN model
mi_dir_adhd_overlap = proj_dir + '/DATA/MI_TABLE/mi_adhd_overlap.npy'
mi_dir_control_overlap = proj_dir + '/DATA/MI_TABLE/mi_control_overlap.npy'

# save accuracy and trained models
result_dir = proj_dir + '/DATA/RESULTS'
model_dir = proj_dir + '/DATA/MODELS'

epoch_adhd_dir = proj_dir + '/DATA/MI_TABLE/num_epoch_ADHD.npy'
epoch_control_dir = proj_dir + '/DATA/MI_TABLE/num_epoch_CONTROL.npy'
#endregion

#region Create Graph Dataset from MI tables
### Graph - Training/Validation
## This dataset will be split into training set and validation set
#  Load mutual information matrices
ADHD_mi = np.load(mi_dir_adhd)
CONTROL_mi = np.load(mi_dir_control)

ADHD_corr = np.load(corr_dir_adhd)
CONTROL_corr = np.load(corr_dir_control)

#  Get number of epochs for each ADHD patient.
epo_per_adhd = np.load(epoch_adhd_dir)
epo_per_control = np.load(epoch_control_dir)

# dataset contains list of lists. each list contains graph for each patient for each epoch.
count=0
dataset_graph = []
for i in epo_per_adhd:
    patient_mi = ADHD_mi[count:count+int(i),:,:]
    patient_train_val_graph = getGraph(patient_mi, y=1)
    dataset_graph.append(patient_train_val_graph)
    count+=int(i)

count=0
for i in epo_per_control:
    patient_mi = CONTROL_mi[count:count+int(i),:,:]
    patient_train_val_graph = getGraph(patient_mi, y=0)
    dataset_graph.append(patient_train_val_graph)
    count+=int(i)
#endregion

#region Create Graph Test Set
# Test set is created by taking the average value 
# of all mutual information tables for each patient.

# For each patient, find mean value of all MI tables
# Then create new test datapoint.
adhd_test_mi = np.zeros((61,20,20))
n=0
for i, num_epo in enumerate(epo_per_adhd):
    num_epo = int(num_epo)
    adhd_test_mi[i, :, :]= np.mean(ADHD_mi[n:n+num_epo, : , : ])
    n+=num_epo

# same procedure for control group
control_test_mi = np.zeros((60,20,20))
n=0
for i, num_epo in enumerate(epo_per_control):
    num_epo = int(num_epo)
    control_test_mi[i, :, :]= np.mean(CONTROL_mi[n:n+num_epo, : , : ])
    n+=num_epo

# getGraph function to turn this into a pyG graph data format
adhd_test_graph = getGraph(adhd_test_mi, y=1)
control_test_graph = getGraph(control_test_mi, y=0)

test_graph = adhd_test_graph + control_test_graph
# very important to shuffle. Unshuffled data does not learn.
random.shuffle(test_graph)
#endregion 

# This is the summary of graph data objects.
# Graph constructed from the 1st 4 seconds of recording from 100th patient
data = dataset_graph[100][1]
print(f'Label: {data.y}')
print(f'Number of nodes: {data.num_nodes}')
print(f'Number of edges: {data.num_edges}')
print(f'Has isolated nodes: {data.has_isolated_nodes()}')
print(f'Has self-loops: {data.has_self_loops()}')
print(f'Is undirected: {data.is_undirected()}')
print(f'Number of features: {data.num_node_features}')


#region Create Image Dataset
ADHD_mi_overlap = np.load(mi_dir_adhd_overlap)
CONTROL_mi_overlap = np.load(mi_dir_control_overlap)

n_ch = 4 # Motivated by R, G, B, Alpha channels
(ADHD_epochs, channels, channels) = ADHD_mi_overlap.shape
(CONTROL_epochs, channels, channels) = CONTROL_mi_overlap.shape

# Number of images
num_img_ADHD = int(ADHD_epochs/n_ch)
num_img_CONTROL = int(CONTROL_epochs/n_ch)
n_img = num_img_ADHD+num_img_CONTROL

# Target dataset dimension
img_data = np.zeros((n_img, n_ch, channels, channels))
label = np.zeros(n_img)

# select every 4 MI tables and assign it to img_data. This simply raises ADHD_mi_overlap's dimension by 1.
for img in range(num_img_ADHD):
    img_data[img, :, :, :] = ADHD_mi_overlap[n_ch*img:n_ch*(img+1), :, :]
    label[img] = 1
for img in range(num_img_CONTROL):
    img_data[num_img_ADHD+img, :, :, :] = CONTROL_mi_overlap[n_ch*img : n_ch*(img+1), :, :]
    label[num_img_ADHD+img] = 0

# just like any other image dataset, all values are normalized to values between 0 and 1.
for img in range(n_img):
    for ch in range(n_ch):
        img_data[img, ch, :, :] = (img_data[img, ch, :, :]) / (np.max(img_data[img, ch, :, :]))

# TensorDataset class does not have in-built shuffle function.
# list of integers upt to 995 is shuffled and used as an index to shuffle label and img_data.
rand_idx = np.arange(996)
np.random.shuffle(rand_idx)
img_data = img_data[rand_idx, : , : , :]
label = label[rand_idx]

img_data = torch.Tensor(img_data)
label = torch.Tensor(label)
label = label.long() # loss function requires this
dataset_image = TensorDataset(img_data, label) #  Dataset class construction
#endregion

print('Number of ADHD images',num_img_ADHD)
print('Number of CONTROL images',num_img_CONTROL)
print('Total images',n_img)
print('Train-Validation Image Dataset Shape',img_data.shape)


#region Create Image Test Set
epo_per_adhd = np.load(epoch_adhd_dir)
epo_per_control = np.load(epoch_control_dir)

adhd_test_img = np.zeros((61,4,29,29))
control_test_img = np.zeros((60,4,29,29))
test_label = np.zeros(121)

# since image data is 3 dimensional, there were several ways to average image for patient.
n=0
for i, n_epo_patient in enumerate(epo_per_adhd):
    n_im_patient = int(n_epo_patient/n_ch)
    im_patient = np.zeros((n_im_patient, 4, 29, 29))
    for j in range(n_im_patient):
        im_patient[j , : , : , :] = ADHD_mi_overlap[n+j*4 : n+(j+1)*4] # I found the images that would be in img_data.
    adhd_test_img[i, :, :, :]= np.mean(im_patient, axis=0) # then averaged the images element-wise.
    test_label[i]=1
    n+=int(n_epo_patient)

n=0
print(n)
for i, n_epo_patient in enumerate(epo_per_control):
    n_im_patient = int(n_epo_patient/n_ch)
    im_patient = np.zeros((n_im_patient, 4, 29, 29))
    for j in range(n_im_patient):
        im_patient[j , : , : , :] = CONTROL_mi_overlap[n+j*4 : n+(j+1)*4]
    control_test_img[i, :, :, :]= np.mean(im_patient, axis=0)
    n+=int(n_epo_patient)

test_img = np.concatenate((adhd_test_img, control_test_img), axis = 0)

# test set is shuffled in the same manner
rand_idx = np.arange(121)
np.random.shuffle(rand_idx)
test_img = test_img[rand_idx, : , : , :]
test_label = test_label[rand_idx]

test_img = torch.Tensor(test_img)
test_label = torch.Tensor(test_label)
test_label = test_label.long()
test_dataset_img = TensorDataset(test_img, test_label)
#endregion


main_func("SAGE", dataset_graph, test_graph, model_dir, result_dir, 1, 10, 10)