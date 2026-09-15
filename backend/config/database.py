from mysql.connector import Error, connect

from backend.config.settings import Settings


def get_connection():
    """Create a MySQL connection using local environment settings."""
    return connect(**Settings.DB_CONFIG)


def check_connection():
    """Return whether the configured database can be reached."""
    connection = None
    try:
        connection = get_connection()
        return connection.is_connected()
    except Error:
        return False
    finally:
        if connection is not None and connection.is_connected():
            connection.close()
