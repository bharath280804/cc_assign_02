from flask import Flask, render_template, request, redirect, url_for, send_from_directory, flash
import sqlite3
import os
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.secret_key = 'uc_assignment_secret_key'

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATABASE = '/var/www/flaskapp_data/users.db'
UPLOAD_FOLDER = '/var/www/flaskapp_uploads'
ALLOWED_EXTENSIONS = {'txt'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


def get_db_connection():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def word_count_from_file(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        text = f.read()
    words = text.split()
    return len(words)


@app.route('/')
def index():
    return render_template('register.html')


@app.route('/register', methods=['POST'])
def register():
    username = request.form['username']
    password = request.form['password']
    firstname = request.form['firstname']
    lastname = request.form['lastname']
    email = request.form['email']
    address = request.form['address']

    uploaded_file = request.files.get('limerick_file')
    saved_filename = None
    file_word_count = 0

    if uploaded_file and uploaded_file.filename:
        if allowed_file(uploaded_file.filename):
            saved_filename = secure_filename(uploaded_file.filename)
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], saved_filename)
            uploaded_file.save(filepath)
            file_word_count = word_count_from_file(filepath)
        else:
            flash('Only .txt files are allowed.')
            return redirect(url_for('index'))

    conn = get_db_connection()
    conn.execute(
        '''INSERT INTO users (username, password, firstname, lastname, email, address, filename, wordcount)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
        (username, password, firstname, lastname, email, address, saved_filename, file_word_count)
    )
    conn.commit()
    conn.close()

    return redirect(url_for('profile', username=username))


@app.route('/profile/<username>')
def profile(username):
    conn = get_db_connection()
    user = conn.execute('SELECT * FROM users WHERE username = ?', (username,)).fetchone()
    conn.close()
    return render_template('profile.html', user=user)


@app.route('/login')
def login_page():
    return render_template('login.html')


@app.route('/relogin', methods=['POST'])
def relogin():
    username = request.form['username']
    password = request.form['password']

    conn = get_db_connection()
    user = conn.execute(
        'SELECT * FROM users WHERE username = ? AND password = ?',
        (username, password)
    ).fetchone()
    conn.close()

    if user:
        return redirect(url_for('profile', username=username))
    else:
        return '<h2>Invalid username or password</h2><a href="/login">Try Again</a>'


@app.route('/download/<filename>')
def download_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename, as_attachment=True)


if __name__ == '__main__':
    app.run(debug=True)
