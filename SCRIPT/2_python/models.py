import torch
from torch import nn
from torch_geometric.nn import GCNConv, SAGEConv, Linear, global_mean_pool
import torch.nn.functional as F


class SAGE(torch.nn.Module):
    def __init__(self, hidden_channels, k_hop):
        super(SAGE, self).__init__()
        self.k_hop = k_hop
        #torch.manual_seed(12345)
        self.conv1 = SAGEConv(20, hidden_channels)
        self.conv2 = SAGEConv(hidden_channels, hidden_channels)
        self.lin = Linear(hidden_channels, 2)

    def forward(self, x, edge_index, batch):
        for hop in range(self.k_hop):
            if hop==0:
                x = self.conv1(x, edge_index)
                x = x.relu()

            else:
                x = self.conv2(x, edge_index)
                x = x.relu()

        # 2. Readout layer
        x = global_mean_pool(x, batch)  # [batch_size, hidden_channels]

        # 3. Apply a final classifier
        x = F.dropout(x, p=0.5, training=self.training)
        x = self.lin(x)
        return x
    

class GCN(torch.nn.Module):
    def __init__(self, hidden_channels, k_hop):
        super(GCN, self).__init__()
        self.k_hop = k_hop
        torch.manual_seed(12345)
        self.conv1 = GCNConv(20, hidden_channels)
        self.conv2 = GCNConv(hidden_channels, hidden_channels)
        self.lin = Linear(hidden_channels, 2)

    def forward(self, x, edge_index, batch):
        for hop in range(self.k_hop):
            if hop==0:
                x = self.conv1(x, edge_index)
                x = x.relu()
            else:
                x = self.conv2(x, edge_index)
                x = x.relu()

        # 2. Readout layer
        x = global_mean_pool(x, batch)  # [batch_size, hidden_channels]

        # 3. Apply a final classifier
        x = F.dropout(x, p=0.5, training=self.training)
        x = self.lin(x)
        return x

'''
class DIFF(torch.nn.Module):
    def __init__(self, data, hidden_channels,K):
        super(DIFF, self).__init__()
        torch.manual_seed(12345)
        self.conv1 = DCRNN(data.num_node_features, hidden_channels, K)
        self.conv2 = DCRNN(hidden_channels, hidden_channels, K)
        self.lin = Linear(hidden_channels, 2)

    def forward(self, x, edge_index, batch):
        x = self.conv1(x, edge_index)
        x = x.relu()

        # 2. Readout layer
        x = global_mean_pool(x, batch)  # [batch_size, hidden_channels]

        # 3. Apply a final classifier
        
        x = F.dropout(x, p=0.5, training=self.training)
        x = self.lin(x)
        
        return x
'''
    
def weight_init(m):
    if type(m) == nn.Conv2d:
        nn.init.normal_(m.weight)

class CNN(nn.Module):
    def __init__(self, n_ch=4):
        super(CNN, self).__init__()
        self.n_ch = n_ch

        self.part_one = nn.Sequential(
            nn.Conv2d(in_channels=n_ch, out_channels=16, kernel_size=(3,3), padding=1),
            nn.MaxPool2d(kernel_size=(3,3)),
            nn.Dropout(),
            nn.Conv2d(in_channels=16, out_channels=32, kernel_size=(3,3), padding=1))

        self.part_two_a = nn.Sequential(nn.Conv2d(in_channels=32, out_channels=32, kernel_size=(3,3), padding=1))

        self.part_three_1 = nn.Sequential(
            nn.Conv2d(in_channels=32, out_channels=64, kernel_size=(1,1), padding=1),
            nn.Conv2d(in_channels=64, out_channels=128, kernel_size=(3,3), padding=1)
        )

        self.maxpool = nn.MaxPool2d(kernel_size=(3,3))
        self.conv1 = nn.Conv2d(in_channels=128, out_channels=8, kernel_size=(3,3), padding=1)
        self.conv2 = nn.Conv2d(in_channels=128, out_channels=8, kernel_size=(3,3), padding=1)
        self.conv3 = nn.Conv2d(in_channels=128, out_channels=8, kernel_size=(3,3), padding=1)
        self.conv4 = nn.Conv2d(in_channels=128, out_channels=8, kernel_size=(3,3), padding=1)

        self.fc = nn.Linear(in_features=32, out_features=2)
        self.softmax = nn.Softmax(dim=1)
        self.relu = nn.ReLU()
        self.tanh = nn.Tanh()
        self.bn = nn.BatchNorm2d(8)

        self.part_one.apply(weight_init)
        self.part_two_a.apply(weight_init)
        self.part_three_1.apply(weight_init)
        nn.init.normal_(self.conv1.weight)
        nn.init.normal_(self.conv2.weight)
        nn.init.normal_(self.conv3.weight)
        nn.init.normal_(self.conv4.weight)
        nn.init.normal_(self.fc.weight)

    def part_three(self, x):

        x = self.part_three_1(x)
        x1 = self.maxpool(x)
        x1 = self.conv1(x1)

        x1 = self.bn(x1)
        x1 = nn.functional.max_pool2d(input=x1, kernel_size=x1.shape[2:])
        x1 = self.relu(x1)

        x2 = self.maxpool(x)
        x2 = self.conv2(x2)
        x2 = self.bn(x2)
        x2 = nn.functional.avg_pool2d(input=x2, kernel_size=x2.shape[2:])
        x2 = self.tanh(x2)

        x3 = self.maxpool(x)
        x3 = self.conv3(x3)
        x3 = self.bn(x3)
        x3 = nn.functional.max_pool2d(input=x3, kernel_size=x3.shape[2:])
        x3 = self.relu(x3)

        x4 = self.maxpool(x)
        x4 = self.conv4(x4)
        x4 = self.bn(x4)
        x4 = nn.functional.avg_pool2d(input=x4, kernel_size=x4.shape[2:])
        x4 = self.tanh(x4)

        x = torch.cat((x1,x2,x3,x4),1)
        x = torch.squeeze(x)
        return x

    def forward(self, x):
        x = self.part_one(x)
        x = self.part_two_a(x)
        x = self.part_three(x)
        x = self.fc(x)
        x = self.softmax(x)
        return x