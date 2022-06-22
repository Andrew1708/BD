#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request
import psycopg2
import psycopg2.extras

## SGBD configs
DB_HOST = "db.tecnico.ulisboa.pt"
DB_USER = "ist199077"
DB_DATABASE = DB_USER
DB_PASSWORD = "1234"
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
        data = (nome_cat,)
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
        query = "start transaction;\
                INSERT INTO categoria VALUES ('%s');\
                INSERT INTO categoria_simples VALUES ('%s');\
                commit;" %(nome,nome)

        data = (nome,)
        cursor.execute(query, data)
        return lista_categorias()
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route("/update_subcat", methods=["POST"])
def update_subcategoria():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        nomeSuper = request.form["nomeSuper"]
        nomeSub = request.form["nomeSub"]
        query = "start transaction;\
                DELETE FROM categoria_simples WHERE nome = '%s';\
                INSERT INTO super_categoria VALUES ('%s');\
                INSERT INTO tem_outra VALUES ('%s','%s')\
                commit;" %(nomeSuper,nomeSuper, nomeSub, nomeSuper)

        data = (nomeSuper,nomeSub)
        cursor.execute(query, data)
        
        return lista_categorias()
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()
#5. b)
@app.route("/retalhista")
def lista_retalhista():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM retalhista"
        cursor.execute(query)
        return render_template("retalhista.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route("/escolhe_sub")
def escolhe_sub():
    try:
        return render_template("add_subcategoria.html", params=request.args)
    except Exception as e:
        return str(e)
# 5. c)        
@app.route("/escolhe_ivm")
def escolhe_ivm():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT *\
                 FROM ivm"
        cursor.execute(query)
        return render_template("escolhe_ivm.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route("/event_rep", methods=["POST"])
def listar_eventos():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        nr_serie = request.form["nr_serie"]
        fab = request.form["fab"]
        query = "SELECT ean, nro, num_serie, fabricante, instante, unidades, cat, sum\
                 FROM(\
                        (SELECT cat, SUM(unidades) as sum\
                        FROM evento_reposicao NATURAL JOIN produto\
                        GROUP BY cat) soma\
                        NATURAL JOIN evento_reposicao NATURAL JOIN produto\
                    )\
                 WHERE num_serie =%s AND fabricante =%s;" #%nr_serie %fab
        data = (nr_serie, fab)
        cursor.execute(query, data)
        return render_template("event_rep.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

#5 d) 
@app.route("/tree_cat")
def tree_cat():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "WITH RECURSIVE subordinates AS(\
                 SELECT categoria, super_categoria\
                 FROM tem_outra\
                 WHERE super_categoria = 'Bebidas'\
                 UNION\
                    SELECT t.categoria, t.super_categoria\
                    FROM tem_outra t\
                    INNER JOIN subordinates s on s.categoria = t.super_categoria\
                )\
                SELECT *\
                FROM subordinates"
        cursor.execute(query)
        return render_template("tree_cat.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()


CGIHandler().run(app)
