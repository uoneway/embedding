#!/usr/bin/env bash

COMMAND=$1

case $COMMAND in
    process-nsmc)
        echo "process nsmc raw json.."
        python preprocess/dump.py nsmc-json /Users/david/works/nsmc/raw data/review_movieid.txt
        ;;
    process-nsmc-nouns)
        echo "process nsmc raw json, extract nouns.."
        python preprocess/dump.py nsmc-json-nouns /Users/david/works/nsmc/raw data/review_movieid_nouns.txt
        ;;
    lsa-tfidf)
        echo "latent semantic analysis with tf-idf matrix..."
        python models/sent_utils.py latent_semantic_analysis data/review_movieid_nouns.txt data/lsa-tfidf.vecs
        ;;
    doc2vec)
        echo "doc2vec..."
        python models/sent_utils.py doc2vec data/review_movieid.txt data/doc2vec.vecs
        ;;
    lda)
        echo "latent_dirichlet_allocation..."
        python models/sent_utils.py latent_dirichlet_allocation data/review_movieid_nouns.txt data/lda
        ;;
    train-elmo)
        echo "train ELMo..."
        python models/sent_utils.py construct_elmo_vocab data/corpus_mecab.txt data/elmo-vocab.txt
        # options.json (small)
        scp -P 30800 models/train_elmo.py ratsgo@112.217.184.162:~/bilm-tf
        scp -P 30800 models/bilm/* ratsgo@112.217.184.162:~/bilm-tf/bilm
        scp -P 30800 data/corpus_mecab.txt ratsgo@112.217.184.162:~/data
        scp -P 30800 data/elmo-vocab.txt ratsgo@112.217.184.162:~/data
        # @workstation
        mkdir data/traindata
        split -l 20000 data/corpus_mecab.txt data/traindata/data_
        cd ~/bilm-tf
        source ~/tf120/bin/activate
        export CUDA_VISIBLE_DEVICES=0,1
        export LC_CTYPE=C.UTF-8
        python3.6 train_elmo.py \
            --train_prefix='/home/ratsgo/data/traindata/*' \
            --vocab_file /home/ratsgo/data/elmo-vocab.txt \
            --save_dir /home/ratsgo/elmo-model
        ;;
    dump-elmo)
        echo "dump pretrained ELMo weights..."
        python models/sent_utils.py dump_elmo_weights data/elmo/checkpoint data/elmo/elmo.model
        ;;
    dump-bert)
        echo "dump pretrained BERT weights..."
        wget https://storage.googleapis.com/bert_models/2018_11_23/multi_cased_L-12_H-768_A-12.zip
        mv multi_cased_L-12_H-768_A-12.zip data/bert
        cd data/bert
        unzip multi_cased_L-12_H-768_A-12.zip
        ;;
esac