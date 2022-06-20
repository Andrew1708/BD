#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request
import psycopg2
import psycopg2.extras

## SGBD configs
DB_HOST = "db.tecnico.ulisboa.pt"
DB_USER = "ist192737"
DB_DATABASE = DB_USER
DB_PASSWORD = "Morgado1"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (
    DB_HOST,
    DB_DATABASE,
    DB_USER,
    DB_PASSWORD,
)

app = Flask(__name__)


@app.route("/")
def list_accounts():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM evento_reposicao;"
        cursor.execute(query)
        return render_template("index.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()


@app.route("/categoria")
def lista_categorias():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM categoria;"
        cursor.execute(query)
        return render_template("categoria.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route("/elimina_categoria")
def elimina_categoria():
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        nome_cat = request.args.get("nome")
        query = "DELETE FROM categoria WHERE nome = '%s';" %nome_cat
        data = nome_cat
        cursor.execute(query, data)
        return query
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route("/add_categoria")
def add_categoria():
    try:
        return render_template("add_categoria.html", params=request.args)
    except Exception as e:
        return str(e)

@app.route("/update_cat", methods=["POST"])
def update_categoria():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        nome = request.form["nome"]
        query = "INSERT INTO categoria VALUES ('%s');" %nome 
        data = (nome)
        cursor.execute(query, data)
        return query
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


CGIHandler().run(app)
