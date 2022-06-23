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

@app.route("/menu")
def menu():
    try:
        return render_template("menu.html", params=request.args)
    except Exception as e:
        return str(e)

@app.route("/")
def index():
    try:
        return render_template("menu.html", params=request.args)
    except Exception as e:
        return str(e)


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

@app.route("/escolhe_sub")
def escolhe_sub():
    try:
        return render_template("add_subcategoria.html", params=request.args)
    except Exception as e:
        return str(e)

@app.route("/update_subcat", methods=["POST"])
def update_subcategoria():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        nomeSuper = request.form["nomeSuper"]
        nomeSub = request.form["nomeSub"]


        query1 = "SELECT * FROM super_categoria WHERE nome = %s" %nomeSuper
        data1 = (nomeSuper,)
        cursor.execute(query1, data1)
        row = cursor.fetchone()
        if row == None:
            query2 = "INSERT INTO tem_outra VALUES ('%s','%s')" %(nomeSuper,nomeSub)
            data2 = (nomeSuper,nomeSub)
            cursor.execute(query2, data2)
        else:
            query3 = "DELETE FROM categoria_simples WHERE nome = '%s'\
                    INSERT INTO super_categoria VALUES ('%s');\
                    INSERT INTO tem_outra VALUES ('%s','%s')" %(nomeSuper,nomeSuper,nomeSub, nomeSuper)
            data3 = (nomeSuper,nomeSub)
            cursor.execute(query3, data3)
        
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

@app.route("/add_retalhista")
def add_retalhista():
    try:
        return render_template("add_retalhista.html", params=request.args)
    except Exception as e:
        return str(e)

@app.route("/update_retalhista", methods=["POST"])
def update_retalhista():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        nome = request.form["nome"]
        tin = request.form["tin"]
        query = "start transaction;\
                INSERT INTO retalhista VALUES ('%s','%s');\
                commit;" %(tin, nome)

        data = (nome,tin)
        cursor.execute(query, data)
        return lista_retalhista()
    except Exception as e:
        e = "Erro ao adicionar retalhista"
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route("/elimina_retalhista")
def elimina_retalhista():
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        tin = request.args.get("tin")
        query = "start transaction;\
                DELETE FROM evento_reposicao WHERE tin = %s;\
                DELETE FROM responsavel_por WHERE tin = %s;\
                DELETE FROM retalhista WHERE tin = %s;\
                commit;" %(tin, tin, tin)
        data = (tin,)
        cursor.execute(query, data)
        return lista_retalhista()
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

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

@app.route("/event_rep")
def listar_eventos():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        dados = request.args.get("dados")
        dados = list(map(str, dados.split(', ')))
        dados[0]= int(dados[0])
        query = """SELECT ean, nro, num_serie, fabricante, instante, unidades, cat, sum
                 FROM(
                        (SELECT cat, SUM(unidades) as sum
                        FROM evento_reposicao NATURAL JOIN produto
                        GROUP BY cat) soma
                        NATURAL JOIN evento_reposicao NATURAL JOIN produto
                    )
                 WHERE num_serie =%s AND fabricante =%s;""" 
        data = (dados[0], dados[1])
        cursor.execute(query, data)
        return render_template("event_rep.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()



#5 d) 
@app.route("/escolhe_tree")
def escolhe_tree():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = """SELECT *
                   FROM super_categoria"""
        cursor.execute(query)
        return render_template("escolhe_tree.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route("/tree_cat", methods=["POST"])
def tree_cat():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        super_cat = request.form["super_categoria"]
        query = """WITH RECURSIVE subordinates AS(
                 SELECT categoria
                 FROM tem_outra
                 WHERE super_categoria = %s
                 UNION
                    SELECT t.categoria
                    FROM tem_outra t
                    INNER JOIN subordinates s on s.categoria = t.super_categoria
                )
                SELECT *
                FROM subordinates"""
        data = (super_cat,)
        cursor.execute(query, data)
        return render_template("tree_cat.html", cursor=cursor, super_categoria = super_cat)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()


CGIHandler().run(app)
