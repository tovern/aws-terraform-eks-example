import app

with app.app_context():
    app.db.create_all()
