local main: Frame = Instance.new('Frame', songdisplay);
main.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
main.BorderSizePixel = 0
main.Size = UDim2.new(0, 229, 0, 82);
main.Position = UDim2.new(0.011, 0, 0.029, 0);

local bar: Frame = Instance.new('Frame', main);
bar.BorderSizePixel = 0
bar.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
bar.Size = UDim2.new(0, 78, 0, 2);
bar.Position = UDim2.new(0.459, 0, 0.69, 0);

Instance.new('UIListLayout', bar)

local updatedbar: Frame = Instance.new('Frame', bar);
updatedbar.BorderSizePixel = 0
updatedbar.BackgroundColor3 = Color3.fromRGB(251, 142, 142);
updatedbar.Size = UDim2.new(0, 78, 0, 2);

local songcover: ImageLabel = Instance.new('ImageLabel', main);
songcover.BackgroundTransparency = 1;
songcover.Size = UDim2.new(0, 57, 0, 57);
songcover.Position = UDim2.new(0.04, 0, 0.144, 0);

local songtitle: TextLabel = Instance.new('TextLabel', main);
songtitle.BackgroundTransparency = 1;
songtitle.Size = UDim2.new(0, 200, 0, 14);
songtitle.Position = UDim2.new(0.323, 0, 0.22, 0);
songtitle.Font = Enum.Font.ArimoBold;
songtitle.TextSize = 14;
songtitle.Text = 'None';
songtitle.TextYAlignment = Enum.TextYAlignment.Top;
songtitle.TextXAlignment = Enum.TextXAlignment.Left;

local songartist: TextLabel = Instance.new('TextLabel', main);
songartist.BackgroundTransparency = 1;
songartist.Size = UDim2.new(0, 200, 0, 14);
songartist.Position = UDim2.new(0.323, 0, 0.41, 0);
songartist.Font = Enum.Font.Arimo;
songartist.TextSize = 11;
songartist.Text = 'By none';
songartist.TextYAlignment = Enum.TextYAlignment.Top;
songartist.TextXAlignment = Enum.TextXAlignment.Left;

local songcurrent: TextLabel = Instance.new('TextLabel', main);
songcurrent.BackgroundTransparency = 1;
songcurrent.Size = UDim2.new(0, 200, 0, 14);
songcurrent.Position = UDim2.new(0.323, 0, 0.634, 0);
songcurrent.Font = Enum.Font.Arimo;
songcurrent.TextSize = 11;
songcurrent.Text = '00:00';
songcurrent.TextYAlignment = Enum.TextYAlignment.Top;
songcurrent.TextXAlignment = Enum.TextXAlignment.Left;

local songmax: TextLabel = Instance.new('TextLabel', main);
songmax.BackgroundTransparency = 1;
songmax.Size = UDim2.new(0, 200, 0, 14);
songmax.Position = UDim2.new(0.83, 0, 0.634, 0);
songmax.Font = Enum.Font.Arimo;
songmax.TextSize = 11;
songmax.Text = '09:59';
songmax.TextYAlignment = Enum.TextYAlignment.Top;
songmax.TextXAlignment = Enum.TextXAlignment.Left;
