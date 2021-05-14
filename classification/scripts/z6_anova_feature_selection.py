#
# anova_feature_selection.py
#
# z katalogu --input-dir
# trzy pliki: train_data.pkl, test_data.pkl, class_names.pkl
#
# Uczy się na danych z train_data.pkl wyliczając ANOVA i wybierając k-najlepszych cech
# To same cechy wybiera z train_data.pkl
# Wynik zapisywany jest do --output-dir

# UWAGA zarówno output- jak i input-dir wpisujemy z '\' (na windowsie) lub '/' (na Linuxie) na końcu ścieżki

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
# from sklearn.manifold import TSNE
# from sklearn import decomposition
from sklearn.feature_selection import SelectKBest, f_classif
# from sklearn import datasets, metrics
# from sklearn.manifold import TSNE
from sklearn.metrics import classification_report

import time
import argparse

from sklearn.model_selection import train_test_split
import pickle

# from sklearn.naive_bayes import GaussianNB
# from sklearn.neighbors import KNeighborsClassifier
# from sklearn.svm import SVC


def read_data(input_dir):
    # wczytujemy dane treningowe:
    train_data_infile = open(input_dir + 'train_data.pkl', 'rb')  # czytanie z pliku
    data_train_all_dict = pickle.load(train_data_infile)

    x_train = data_train_all_dict["data"]
    y_train = data_train_all_dict["classes"]

    # wczytujemy dane testowe:
    test_data_infile = open(input_dir + 'test_data.pkl', 'rb')  # czytanie z pliku
    data_test_all_dict = pickle.load(test_data_infile)

    x_test = data_test_all_dict["data"]

    y_test = data_test_all_dict["classes"]

    # i nazwy klas
    cl_names_infile = open(input_dir + 'class_names.pkl', 'rb')
    classes_names = pickle.load(cl_names_infile)

    print("Data loaded from " + input_dir)

    return x_train, y_train, x_test, y_test, classes_names


def save_data(x_train, y_train, x_test, y_test, classes_names, output_dir):
    # zapisujemy dane treningowe
    x_train_all_dict = {'data': x_train,
                        'classes': y_train}

    train_data_outfile = open(output_dir + 'train_data.pkl', 'wb')
    pickle.dump(x_train_all_dict, train_data_outfile)

    # zapisujemy dane testowe
    x_test_all_dict = {'data': x_test,
                       'classes': y_test}

    test_data_outfile = open(output_dir + 'test_data.pkl', 'wb')
    pickle.dump(x_test_all_dict, test_data_outfile)

    # zapisujemy nazwy klas
    cl_names_outfile = open(output_dir + 'class_names.pkl', 'wb')
    pickle.dump(classes_names, cl_names_outfile)

    print("Pickles saved in ", output_dir)


def ParseArguments():
    parser = argparse.ArgumentParser(description="Project")
    parser.add_argument('--input-dir', default="", required=True, help='data dir (default: %(default)s)')
    parser.add_argument('--output-dir', default="", required=True, help='output dir (default: %(default)s)')
    parser.add_argument('--n', default="", required=True, help='output dir (default: %(default)s)')
    args = parser.parse_args()

    return args.input_dir, args.output_dir, args.n


input_dir, output_dir, n_comp = ParseArguments()

n_comp = int(n_comp)

# wczytujemy dane
x_train, y_train, x_test, y_test, classes_names = read_data(input_dir)

###ANOVA

print("ANOVA reduction ", x_train.shape[1], " -> ", n_comp,  " ...",  end =" ")

anova_filter = SelectKBest(f_classif, k=n_comp)

## wwybranie odpowiednich cech na podstawie wyliczeń wykonanych na x_train
start_time = time.time()
x_train_reduced =  anova_filter.fit_transform(x_train, y_train)
print("  took %s seconds " % round((time.time() - start_time),5))

# wybranie tych samych cech z x_test

x_test_reduced = anova_filter.transform(x_test)


# zapisujemy dane

save_data(x_train_reduced, y_train, x_test_reduced, y_test, classes_names, output_dir)
