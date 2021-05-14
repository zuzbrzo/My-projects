from sklearn import datasets
from sklearn.feature_selection import SelectKBest, mutual_info_classif
from functools import partial
import time
import pickle
from pylab import show, figure

def read_data(input_dir):
    # wczytujemy dane treningowe:
    train_data_infile = open(input_dir + '/train_data.pkl', 'rb')  # czytanie z pliku
    data_train_all_dict = pickle.load(train_data_infile)

    x_train = data_train_all_dict["data"]
    y_train = data_train_all_dict["classes"]

    # wczytujemy dane testowe:
    test_data_infile = open(input_dir + '/test_data.pkl', 'rb')  # czytanie z pliku
    data_test_all_dict = pickle.load(test_data_infile)

    x_test = data_test_all_dict["data"]

    y_test = data_test_all_dict["classes"]

    # i nazwy klas
    cl_names_infile = open(input_dir + '/class_names.pkl', 'rb')
    classes_names = pickle.load(cl_names_infile)

    print("Data loaded from " + input_dir)

    return x_train, y_train, x_test, y_test, classes_names

input_dir = input("Adres pliku:")

x_train,y_train, x_test,y_test,classes_names = read_data(input_dir)

print("Twoje dane mają rozmiar:",x_train.shape[1])

n_comp = 3

fs = SelectKBest(score_func=partial(mutual_info_classif, n_neighbors=3), k=int(n_comp))
start_time = time.time()
x_train_reduced = fs.fit_transform(x_train,y_train)
print("  took %s seconds " % round((time.time() - start_time),5))
x_test_reduced = fs.transform(x_test)

new = x_train_reduced
col = y_train
fig = figure(figsize=(10,10))
ax = fig.add_subplot(111,projection='3d')
ax.scatter(new[:,0], new[:,1], new[:,2], c=col, marker ="x")
show()
