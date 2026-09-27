chmod 400 CC_assign_2.pkk
ssh -i CC_assign_2.pkk ubuntu@ec2-3-139-240-171.us-east-2.compute.amazonaws.com
sudo apt-get update
sudo apt-get install -y apache2
sudo apt install -y libapache2-mod-wsgi-py3
sudo apt install -y python3-pip
sudo apt install -y python3-flask
sudo apt install -y sqlite3
sudo chmod 755 /home/ubuntu/
python3 --version
pip3 --version
sqlite3 --version
apache2 -v
mkdir -p /home/ubuntu/flaskapp/templates
mkdir -p /home/ubuntu/flaskapp/static
cd /home/ubuntu/flaskapp
sudo mkdir -p /var/www/flaskapp_uploads
sudo chown -R www-data:www-data /var/www/flaskapp_uploads
sudo chmod -R 775 /var/www/flaskapp_uploads
sudo mkdir -p /var/www/flaskapp_data
sudo chown -R www-data:www-data /var/www/flaskapp_data
sudo chmod -R 775 /var/www/flaskapp_data
sudo mkdir -p /var/www/flaskapp_uploads
sudo chown -R www-data:www-data /var/www/flaskapp_uploads
sudo chmod -R 775 /var/www/flaskapp_uploads
sudo mkdir -p /var/www/flaskapp_data
sudo chown -R www-data:www-data /var/www/flaskapp_data
sudo chmod -R 775 /var/www/flaskapp_data
cat > /home/ubuntu/flaskapp/app.py <<'EOF'
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
EOF

cat > /home/ubuntu/flaskapp/init_db.py <<'EOF'
import sqlite3

conn = sqlite3.connect('/var/www/flaskapp_data/users.db')
cursor = conn.cursor()

cursor.execute('''
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    password TEXT NOT NULL,
    firstname TEXT NOT NULL,
    lastname TEXT NOT NULL,
    email TEXT NOT NULL,
    address TEXT NOT NULL,
    filename TEXT,
    wordcount INTEGER
)
''')

conn.commit()
conn.close()

print('Database initialized successfully.')
EOF

[200~nano /home/ubuntu/flaskapp/app.py~
nano /home/ubuntu/flaskapp/app.py
nano /home/ubuntu/flaskapp/init_db.py
nano /home/ubuntu/flaskapp/templates/register.html
nano /home/ubuntu/flaskapp/templates/login.html
nano /home/ubuntu/flaskapp/templates/profile.html
cd /home/ubuntu/flaskapp
python3 init_db.py
sqlite3 users.db
nano /home/ubuntu/flaskapp/flaskapp.wsgi
sudo nano /etc/apache2/sites-available/flaskapp.conf
sudo a2dissite 000-default.conf
sudo a2ensite flaskapp.conf
sudo systemctl restart apache2
sudo systemctl status apache2
tail /var/log/apache2/error.log
nano /home/ubuntu/flaskapp/templates/register.html
nano /home/ubuntu/flaskapp/templates/login.html
nano /home/ubuntu/flaskapp/templates/profile.html
[200~nano /home/ubuntu/flaskapp/templates/register.html
nano /home/ubuntu/flaskapp/templates/login.html
sudo systemctl restart apache2
grep -n "def index\|render_template" /home/ubuntu/flaskapp/app.py
nano /home/ubuntu/flaskapp/templates/register.html
sudo systemctl restart apache2
sudo tail -n 50 /var/log/apache2/flaskapp_error.log
grep -E "DATABASE|UPLOAD_FOLDER" /home/ubuntu/flaskapp/app.py
ls -ld /var/www/flaskapp_uploads
ls -l /var/www/flaskapp_data/users.db
[200~cat > /home/ubuntu/flaskapp/app.py <<'EOF'
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
EOF~
sudo mkdir -p /var/www/flaskapp_uploads
sudo mkdir -p /var/www/flaskapp_data
sudo chown -R www-data:www-data /var/www/flaskapp_uploads
sudo chown -R www-data:www-data /var/www/flaskapp_data
sudo chmod -R 775 /var/www/flaskapp_uploads
sudo chmod -R 775 /var/www/flaskapp_data

cat > /home/ubuntu/flaskapp/app.py <<'EOF'
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
EOF

sudo mkdir -p /var/www/flaskapp_uploads
sudo mkdir -p /var/www/flaskapp_data
sudo chown -R www-data:www-data /var/www/flaskapp_uploads
sudo chown -R www-data:www-data /var/www/flaskapp_data
sudo chmod -R 775 /var/www/flaskapp_uploads
sudo chmod -R 775 /var/www/flaskapp_data
cat > /home/ubuntu/flaskapp/init_db.py <<'EOF'
import sqlite3

conn = sqlite3.connect('/var/www/flaskapp_data/users.db')
cursor = conn.cursor()

cursor.execute('''
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    password TEXT NOT NULL,
    firstname TEXT NOT NULL,
    lastname TEXT NOT NULL,
    email TEXT NOT NULL,
    address TEXT NOT NULL,
    filename TEXT,
    wordcount INTEGER
)
''')

conn.commit()
conn.close()

print('Database initialized successfully.')
EOF

python3 /home/ubuntu/flaskapp/init_db.py
sudo systemctl restart apache2
grep -E "DATABASE|UPLOAD_FOLDER" /home/ubuntu/flaskapp/app.py
python3 --version
pip3 --version
sqlite3 --version
apache2 -v
ls -la /home/ubuntu/flaskapp
cd /home/ubuntu/flaskapp && python3 init_db.py
cd /home/ubuntu/flaskapp && python3 init_db.py ls -la /var/www/flaskapp_data/
sqlite3 --version
cd /home/ubuntu/flaskapp
python3 init_db.py
sudo apt update
sudo apt install python3-venv -y
cd /home/ubuntu/flaskapp
sudo apt-get update
sudo apt-get install -y apache2
sudo apt install -y libapache2-mod-wsgi-py3
sudo apt install -y python3-pip
sudo apt install -y python3-flask
sudo apt install -y sqlite3
sudo chmod 755 /home/ubuntu/
python3 --version
pip3 --version
sqlite3 --version
apache2 -v
mkdir -p /home/ubuntu/flaskapp/templates
mkdir -p /home/ubuntu/flaskapp/static
cd /home/ubuntu/flaskapp
sudo mkdir -p /var/www/flaskapp_uploads
sudo chown -R www-data:www-data /var/www/flaskapp_uploads
sudo chmod -R 775 /var/www/flaskapp_uploads
sudo mkdir -p /var/www/flaskapp_data
sudo chown -R www-data:www-data /var/www/flaskapp_data
sudo chmod -R 775 /var/www/flaskapp_data
nano /home/ubuntu/flaskapp/app.py
nano /home/ubuntu/flaskapp/init_db.py
nano /home/ubuntu/flaskapp/regiister.py
nano /home/ubuntu/flaskapp/register.html
nano /home/ubuntu/flaskapp/login.html
nano /home/ubuntu/flaskapp/profile.html
find /home/ubuntu/flaskapp -maxdepth 2 -type f
python3 -m py_compile flaskapp.py
cd /home/ubuntu/flaskapp
python3 flaskapp.py
sudo apt install sqlite3 -y
sqlite3 --version
sqlite3 kansakri.db
