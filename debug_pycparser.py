import pycparser
from pycparser import c_parser, c_ast, parse_file

def main():
    # Parse the preprocessed file
    parser = c_parser.CParser()
    try:
        ast = parser.parse(open('jpeg.pp.c').read(), filename='jpeg.pp.c')
        ast.show()
    except pycparser.plyparser.ParseError as e:
        print(f"ParseError: {e}")

if __name__ == "__main__":
    main()
