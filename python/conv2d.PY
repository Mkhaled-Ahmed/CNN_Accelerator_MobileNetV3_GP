# import torch
# import torch.nn as nn

# class Conv2DBlock(nn.Module):
#     def __init__(self, in_channels, out_channels, kernel_size=3, padding=1, stride=2):
#         super(Conv2DBlock, self).__init__()
#         self.block = nn.Sequential(
#             nn.Conv2d(in_channels, out_channels, kernel_size, stride, padding),
#             #nn.BatchNorm2d(out_channels),
#             nn.Hardswish()
#         )
    
#     def forward(self, x):
#         return self.block(x)

# # Example usage
# conv_block = Conv2DBlock(in_channels=3, out_channels=16)
# x = torch.randn(1, 3, 224, 224)
# output = conv_block(x)
# print(output.shape)


