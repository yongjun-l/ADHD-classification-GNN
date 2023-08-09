import numpy as np
from sklearn import model_selection
import torch
from torch_geometric.data import Data
import pandas as pd

import time
from sklearn.model_selection import KFold
from torch.utils.data import DataLoader as CNNLoader
from torch_geometric.loader import DataLoader

import models


def getGraph(mi_table, y):
    """
    Input: Adjacency table with shape (epoch, channels, channels). dtype: np.array / y (label) value
    output: List that contains pyG graph data objects for each MI table.
    """
    graphs = []
    (epochs, channels, channels) = mi_table.shape # Get number of epochs and channels

    for epoch in range(epochs):
        edges_np = np.array([[0],[0]]) # Initialize edges matrix
        for row in range(channels):
            for col in range(channels):
                edge = np.array([[row],[col]]) # define fully connected edge matrix of shape (2x400)
                edges_np = np.concatenate((edges_np,edge),axis=1)

                # our data is unweighted
                #weight = np.array([[ADHD_mi[epoch,row,col]]])
                #weights_np = np.concatenate((weights_np, weight),axis=0)

        edges_np = edges_np[:,1:]
        edges = torch.tensor(edges_np, dtype=torch.long)

        # data types are required by the loss function
        y = torch.tensor([y], dtype=torch.int64)
        x = torch.tensor(mi_table[epoch,:,:], dtype=torch.float) # entire MI table is considered as graph data.

        graph = Data(x=x, edge_index=edges, y=y) # Graph data stucture
        graphs.append(graph)
    return graphs

def train(model, loader, loss_fn, optimizer):
    model.train()

    for patient in loader:  # Iterate batches
        #print(patient)
        for data in patient:
            #print(data)
            out = model(data.x, data.edge_index, data.batch)  # forward pass
            loss = loss_fn(out, data.y) # loss
            loss.backward()  # gradient
            optimizer.step()  # update weights
            optimizer.zero_grad()  # clear gradients
    return

def test(model, loader, dataset):
    print("###############")
    correct = 0

    for i,patient in enumerate(loader):
        print('printin patient')
        print(i)
    
    for i,patient in enumerate(loader):
        print("patient",i)
        for data in patient:
            #print(data)
            out = model(data.x, data.edge_index, data.batch)
            pred = out.argmax(dim=1)  # make prediction based on returned softmax values
            correct += int((pred == data.y).sum()) # count correct predictions
    return correct / len(dataset)

# since CNN model does not have data object like GNN, train and test functions were implemented separately.
def train_cnn(model, loader, loss_fn, optimizer):
    correct=0
    for i, data in enumerate(loader):
        inputs, labels = data
        if inputs.shape[0] ==1:  # k-fold would randomly return a fold size that would result in 1 mod batch_size. This was causing dimention error.
            return
        pred = model(inputs)
        loss = loss_fn(pred, labels)
        loss.backward()

        optimizer.step()
        optimizer.zero_grad()

        pred_argmax = pred.argmax(dim=1)
        correct += int((pred_argmax == labels).sum())

def test_cnn(model, loader, dataset):
    correct = 0
    running_loss = 0.0
    for i, data in enumerate(loader):
        inputs, labels = data
        if inputs.shape[0] ==1:
            break
        pred = model(inputs)
        pred_argmax = pred.argmax(dim=1)
        correct += int((pred_argmax == labels).sum())

    return correct / len(dataset)


def main_func(model_name, dataset, test_dataset, model_dir, result_dir, k_hop=1, k_fold=10, n_epo=150, h_ch = 20, lr=0.0001, save=True):
    start = time.time()


    # Implement k-fold cross validation
    kf = KFold(n_splits=k_fold, shuffle=True)

    # For each fold
    for fold, (train_index, valid_index) in enumerate(kf.split(dataset)):

        # Define model, optimizer, and loss function
        if model_name == 'SAGE':
            model = models.SAGE(hidden_channels=h_ch, k_hop=k_hop)
        elif model_name == 'GCN':
            model = models.GCN(hidden_channels=h_ch, k_hop=k_hop)
        #elif model_name == 'DIFF':
        #    model = DIFF(hidden_channels=h_ch, K=k_hop)
        elif model_name =='CNN':
            model = models.CNN()
        else:
            print('Error: model not defined')
            return

        #opt = torch.optim.Adam(model.parameters(), lr=0.01)
        opt = torch.optim.NAdam(model.parameters(), lr=lr, betas = (0.9,0.999), momentum_decay=0.004)
        loss_fnc = torch.nn.CrossEntropyLoss()

        list_train_acc = []
        list_valid_acc = []
        list_test_acc = []

        # Split train, test set and define dataloader
        train_dataset = [dataset[i] for i in train_index]
        valid_dataset = [dataset[i] for i in valid_index]
        print(train_dataset)
        if model_name =='CNN':
            train_loader = CNNLoader(train_dataset, batch_size=128, shuffle=False) # type: ignore
            valid_loader = CNNLoader(valid_dataset, batch_size=32, shuffle=False)
            test_loader = CNNLoader(test_dataset, batch_size=32, shuffle=False)

        else:
            train_loader = DataLoader(train_dataset, batch_size=128, shuffle=False)
            valid_loader = DataLoader(valid_dataset, batch_size=128, shuffle=False)
            test_loader = DataLoader(test_dataset, batch_size=121, shuffle=False)  # whole set

        # For each epoch
        for epoch in range(n_epo):
            print("epoch", epoch)
            if model_name == 'CNN':
                train_cnn(model, train_loader, loss_fnc, opt)
            else:
                train(model, train_loader, loss_fnc, opt)

            # Get accuracy for train and validation set
            if model_name =='CNN':
                train_acc = test_cnn(model, train_loader, train_dataset)
                valid_acc = test_cnn(model, valid_loader, valid_dataset)
                test_acc = test_cnn(model, test_loader, test_dataset)
            else:
                train_acc = test(model, train_loader, train_dataset)
                valid_acc = test(model, valid_loader, valid_dataset)
                test_acc = test(model, test_loader, test_dataset)

            list_train_acc.append(train_acc)
            list_valid_acc.append(valid_acc)
            list_test_acc.append(test_acc)

            #if epoch+1 % 1 ==0:
            print(f'Fold: {fold+1}, Epoch: {epoch+1:03d}, Train: {train_acc:.4f}, Valid: {valid_acc:.4f}, Test: {test_acc:.4f}')

    ####################################
    # Save the results for visualization and analysis
    ####################################
    if save==False:
      return

    # Turn accuracy to numpy array
    list_train_acc = np.array(list_train_acc)
    list_valid_acc = np.array(list_valid_acc)
    list_test_acc = np.array(list_test_acc)

    # Reshape results as column vector
    list_train_acc = np.reshape(list_train_acc, (-1,1))
    list_valid_acc = np.reshape(list_valid_acc, (-1,1))
    list_test_acc = np.reshape(list_test_acc, (-1,1))
    results = np.concatenate((list_train_acc,list_valid_acc,list_test_acc), axis=1)
    results = pd.DataFrame(results, columns=['Train', 'Valid', 'Test'])

    # Save accuracy log
    filename = result_dir+'/kfold_'
    if model_name == 'CNN':
        filename += f'{model_name}_ndam_epo_{n_epo}.csv'
    else:
        filename += f'{model_name}_k_{k_hop}_ndam_epo_{n_epo}_lr_{lr}.csv'
    results.to_csv(filename, float_format='%.3f', index=False, header=True)

    # Save model for later use
    filename_model = model_dir+'/kfold_'
    if model_name == 'CNN':
        filename_model += f'{model_name}.pth'
    else:
        filename_model += f'{model_name}_k_{k_hop}.pth'
    torch.save(model_selection, filename_model)

    # Retain saved model
    # This may not work for other environments due to different path names
    model1 = torch.load(filename_model)
    #test_acc = test(model1, test_loader, test_dataset)
    #print(f'Acc: {test_acc:.4f}')
    print('\nElapsed Time: ',time.time()-start)