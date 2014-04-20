BLAST+
------

Tool:
    `BLAST+ <http://www.ncbi.nlm.nih.gov/books/NBK1762>`_

Version:
    2.2.27+

Purpose:
    BLAST+ is a local alignment program. Unlike global aligners (such as BWA), it does not require that the entire sequence have a match -- rather, it will try to maximize the alignment of a subsequence of the query, above some minimum threshold. Commonly use to find homologies between longer sequences. Not recommended for use with short reads.

Availability:
    BLAST+ is installed on both athyra and the HPCC (through the ``module load BLAST+``), and also has a hosted version at the NCBI site. It is available through debian/Ubuntu repos as well.

Camille's Use Cases:
    I commonly use BLAST+ for basic homology searches, to validate assembled transcripts. blastn (nucleotide to nucleotide) is great for searching mRNA transcripts against a genome reference, while blastx (nucleotide to protein) finds use in searching against more divergent species. For the most divergent species, tblastx (translated nucleotide to translated nucleotide) should be used; for example, when searching mRNA transcripts against microbial genomes for contamination.

    BLAST+ can also be used for basic annotation; see the `Eel Pond Protocol <https://khmer-protocols.readthedocs.org/en/v0.8.4/mrnaseq/>`_ for an example using the older BLASTALL.

Camille's Parameters:
    for ``blastx``
    
    .. code:: 
        
        blastx -query <query.f{a,q}> -db <prot db> -out <out>.csv 
        -num_threads <threads> -evalue .00001 
        -outfmt "10 qseqid sseqid length nident qstart qend sstart send bitscore evalue"
    
    Important parameters are the evalue and format. I usually use 1e-5, though for transcript to reference searches with blastn, I'll kick it up to 1e-10 or more. The example output format is csv, which is really easy to parse with all sorts of tools.

    Remember that you must run ``makeblastdb`` on your database before use!

Performance:
    Rule of thumb is that the more translating needs to be done, the slower it gets by orders of magnitude. blastn is quite fast, but tblastx must check six different reading frames, while also using the larger alignment matrices for proteins. It is very, very slow for databases of any size.


