import argparse

parser = argparse.ArgumentParser()
parser.add_argument('files', nargs="+")
args = parser.parse_args()

if 'README.tex' in args.files:
    print 'README.tex', ' '.join(list(set(args.files) - set(['README.tex'])))
