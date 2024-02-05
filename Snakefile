import glob
import itertools

TEX_FILES = glob.glob("**/*.tex", recursive=True)
BIB_FILES = glob.glob("**/*.bib", recursive=True)

DRAWINGS = [
    f"tmp_figures/layout_large_{','.join([str(y) for y in x])}.pdf"
    for x in set(list(itertools.permutations([0, 0, 0, 1, 1, 1])))
]

rule Paper:
    input:
        DRAWINGS,
        TEX_FILES,
        BIB_FILES,
        "tmp_figures/layout_small_0,0,1,1.pdf",
        "tmp_figures/layout_small_0,1,0,1.pdf",
        ".latexmkrc"
    output:
        "main.pdf",
        "main.bbl"
    threads: 1
    shell: "latexmk main"

rule Arxiv:
    input:
        DRAWINGS,
        TEX_FILES,
        BIB_FILES,
        "main.bbl"
    output:
        "arxiv.tar.gz"
    threads: 1
    shell: "tar -czvf {output} %s" % (" ".join(DRAWINGS + TEX_FILES + BIB_FILES + ["main.bbl", "tmp_figures/layout_small_0,0,1,1.pdf", "tmp_figures/layout_small_0,1,0,1.pdf", "figures/"]))

rule LayoutLargeDrawing:
    input:
        "tikzcommon.tex",
        "palette.tex",
        drawer = "drawings/layout_large.tex"
    output:
        pdf = "tmp_figures/layout_large_{layout}.pdf"
    threads: 1
    shell:
        "pdflatex -shell-escape -halt-on-error -interaction=batchmode -jobname \"tmp_figures/layout_large_{wildcards.layout}\" \"\\def\\layout{{{wildcards.layout}}}\\input{{{input.drawer}}}\""

rule LayoutSmallDrawing:
    input:
        "tikzcommon.tex",
        "palette.tex",
        drawer = "drawings/layout_small.tex"
    output:
        pdf = "tmp_figures/layout_small_{layout}.pdf"
    threads: 1
    shell:
        "pdflatex -shell-escape -halt-on-error -interaction=batchmode -jobname \"tmp_figures/layout_small_{wildcards.layout}\" \"\\def\\layout{{{wildcards.layout}}}\\input{{{input.drawer}}}\""
