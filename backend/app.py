from pathlib import Path

from flask import Flask, render_template

from backend.config.settings import Settings


PROJECT_ROOT = Path(__file__).resolve().parent.parent


def create_app(test_config=None):
    app = Flask(
        __name__,
        template_folder=str(PROJECT_ROOT / "frontend" / "views"),
        static_folder=str(PROJECT_ROOT / "frontend" / "assets"),
    )
    app.config.from_object(Settings)

    if test_config:
        app.config.update(test_config)

    @app.get("/")
    def home():
        return render_template("index.html")

    @app.get("/health")
    def health():
        return {"status": "ok", "service": "tcn"}

    return app


app = create_app()


if __name__ == "__main__":
    app.run()
