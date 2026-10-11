import os
import re
from datetime import datetime, date
from decimal import Decimal
from functools import wraps

from flask import (Flask, render_template, request, redirect, url_for,
                   session, flash, abort)
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import func, or_, text, inspect
from sqlalchemy.exc import DBAPIError, SQLAlchemyError
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from itsdangerous import URLSafeTimedSerializer, BadSignature, SignatureExpired

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "tcn-dev-secret-change-in-production-2026")
app.config.update(
    SQLALCHEMY_DATABASE_URI=os.environ.get(
        "DATABASE_URL", "mysql+pymysql://root:YOUR_MYSQL_PASSWORD@localhost/freelancing_network"),
    SQLALCHEMY_TRACK_MODIFICATIONS=False,
    UPLOAD_FOLDER=os.path.join(app.root_path, "static", "uploads"),
    MAX_CONTENT_LENGTH=5 * 1024 * 1024,  # 5 MB
)
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "gif", "webp"}
os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)
db = SQLAlchemy(app)
Col, FK = db.Column, db.ForeignKey

class Customer(db.Model):
    __tablename__ = "customer"
    customer_id = Col(db.Integer, primary_key=True)
    cus_first_name = Col(db.String(50), nullable=False)
    cus_last_name = Col(db.String(50), nullable=False)
    cus_phone_num = Col(db.String(15), nullable=False)
    cus_email = Col(db.String(100), unique=True, nullable=False)
    password_hash = Col(db.String(255), nullable=False)
    profile_pic = Col(db.String(200), default="default.jpg")

    @property
    def first_name(self): return self.cus_first_name

    @property
    def full_name(self): return f"{self.cus_first_name} {self.cus_last_name}"


class Administrator(db.Model):
    __tablename__ = "administrator"
    admin_id = Col(db.Integer, primary_key=True)
    admin_name = Col(db.String(100), nullable=False)
    admin_email = Col(db.String(100), unique=True)
    password_hash = Col(db.String(255))

    first_name = full_name = property(lambda self: self.admin_name)


class Freelancer(db.Model):
    __tablename__ = "freelancer"
    freelancer_id = Col(db.Integer, primary_key=True)
    f_first_name = Col(db.String(50), nullable=False)
    f_last_name = Col(db.String(50), nullable=False)
    f_phone_num = Col(db.String(15), nullable=False)
    f_email = Col(db.String(100), unique=True, nullable=False)
    password_hash = Col(db.String(255), nullable=False)
    profile_pic = Col(db.String(200), default="default.jpg")
    verification_status = Col(db.String(15), default="pending")
    verification_date = Col(db.Date)
    admin_id = Col(db.Integer, FK("administrator.admin_id"))
    bio = Col(db.String(500))

    @property
    def first_name(self): return self.f_first_name

    @property
    def full_name(self): return f"{self.f_first_name} {self.f_last_name}"


class Location(db.Model):
    __tablename__ = "location"
    location_id = Col(db.Integer, primary_key=True)
    location_name = Col(db.String(100), nullable=False)
    municipality_name = Col(db.String(100), nullable=False)


class ServiceCategory(db.Model):
    __tablename__ = "service_category"
    service_category_id = Col(db.Integer, primary_key=True)
    service_category_name = Col(db.String(50), unique=True, nullable=False)


class Service(db.Model):
    __tablename__ = "service"
    service_id = Col(db.Integer, primary_key=True)
    service_name = Col(db.String(100), unique=True, nullable=False)
    service_category_id = Col(db.Integer, FK("service_category.service_category_id"), nullable=False)
    category = db.relationship("ServiceCategory", backref="services")


class Booking(db.Model):
    __tablename__ = "booking"
    booking_id = Col(db.Integer, primary_key=True)
    booking_date = Col(db.Date, nullable=False)
    scheduled_date = Col(db.Date, nullable=False)
    scheduled_time = Col(db.Time, nullable=False)
    booking_status = Col(db.String(15), default="pending")
    customer_id = Col(db.Integer, FK("customer.customer_id"), nullable=False)
    freelancer_id = Col(db.Integer, FK("freelancer.freelancer_id"), nullable=False)
    location_id = Col(db.Integer, FK("location.location_id"), nullable=False)

    customer = db.relationship("Customer", backref="bookings")
    freelancer = db.relationship("Freelancer", backref="bookings")
    location = db.relationship("Location", backref="bookings")
    services = db.relationship("BookingService", backref="booking", cascade="all, delete-orphan")
    payment = db.relationship("Payment", backref="booking", uselist=False)
    review = db.relationship("Review", backref="booking", uselist=False)


class BookingService(db.Model):
    __tablename__ = "booking_service"
    booking_id = Col(db.Integer, FK("booking.booking_id"), primary_key=True)
    service_id = Col(db.Integer, FK("service.service_id"), primary_key=True)
    hours_booked = Col(db.Numeric(4, 1), nullable=False)
    agreed_hourly_rate = Col(db.Numeric(7, 2), nullable=False)
    service = db.relationship("Service")


class PortfolioImage(db.Model):
    __tablename__ = "portfolio_image"
    image_id = Col(db.Integer, primary_key=True)
    filename = Col(db.String(200), nullable=False)
    caption = Col(db.String(200))
    freelancer_id = Col(db.Integer, FK("freelancer.freelancer_id"), nullable=False)


class Payment(db.Model):
    __tablename__ = "payment"
    payment_id = Col(db.Integer, primary_key=True)
    booking_id = Col(db.Integer, FK("booking.booking_id"), unique=True, nullable=False)
    payment_method = Col(db.String(10), nullable=False)
    payment_date = Col(db.Date, nullable=False)
    payment_amount = Col(db.Numeric(9, 2), nullable=False)
    payment_status = Col(db.String(10), default="pending")


class Review(db.Model):
    __tablename__ = "review"
    review_id = Col(db.Integer, primary_key=True)
    booking_id = Col(db.Integer, FK("booking.booking_id"), unique=True, nullable=False)
    rating = Col(db.Integer, nullable=False)
    review_comment = Col(db.String(300))
    review_date = Col(db.Date, nullable=False)


class SafetyReport(db.Model):
    __tablename__ = "safety_report"
    report_id = Col(db.Integer, primary_key=True)
    booking_id = Col(db.Integer, FK("booking.booking_id"), nullable=False)
    report_type = Col(db.String(10), nullable=False)
    report_reason = Col(db.String(100), nullable=False)
    report_description = Col(db.String(300))
    report_date = Col(db.Date, nullable=False)
    report_status = Col(db.String(15), default="open")
    booking = db.relationship("Booking", backref="safety_reports")


class FreelancerService(db.Model):
    __tablename__ = "freelancer_service"
    freelancer_id = Col(db.Integer, FK("freelancer.freelancer_id"), primary_key=True)
    service_id = Col(db.Integer, FK("service.service_id"), primary_key=True)


# ------------------------------- Helpers ------------------------------------
# (user type, model, email column, id column) - admin first so admin logins win
USER_KINDS = [
    ("admin", Administrator, "admin_email", "admin_id"),
    ("customer", Customer, "cus_email", "customer_id"),
    ("freelancer", Freelancer, "f_email", "freelancer_id"),
]
KIND_MODEL = {k: m for k, m, _, _ in USER_KINDS}


def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if "user_id" not in session:
            flash("Please log in to continue.", "error")
            return redirect(url_for("login", next=request.path))
        return f(*args, **kwargs)
    return decorated


def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if session.get("user_type") != "admin":
            flash("Admin access required.", "error")
            return redirect(url_for("login"))
        return f(*args, **kwargs)
    return decorated


def role_only(role, message):
    """Allow only one user type; others get a flash message and go to the dashboard."""
    def wrap(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if session["user_type"] != role:
                flash(message, "error")
                return redirect(url_for("dashboard"))
            return f(*args, **kwargs)
        return decorated
    return wrap


def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


def serializer():
    return URLSafeTimedSerializer(app.secret_key)


def current_user():
    model = KIND_MODEL.get(session.get("user_type")) if "user_id" in session else None
    return model.query.get(session["user_id"]) if model else None


def find_by_email(email):
    for _, model, email_col, _ in USER_KINDS:
        user = model.query.filter(getattr(model, email_col).ilike(email)).first()
        if user:
            return user
    return None


def owns(booking):
    """True unless a customer/freelancer is touching someone else's booking."""
    kind, uid = session["user_type"], session["user_id"]
    return not ((kind == "customer" and booking.customer_id != uid)
                or (kind == "freelancer" and booking.freelancer_id != uid))


def paid_total(booking_col, user_id=None):
    q = db.session.query(func.coalesce(func.sum(Payment.payment_amount), 0)).join(Booking)
    q = q.filter(Payment.payment_status == "paid")
    return (q.filter(booking_col == user_id) if user_id else q).scalar() or 0


def freelancer_avg_rating(freelancer_id):
    avg, count = (db.session.query(func.avg(Review.rating), func.count(Review.review_id))
                  .join(Booking).filter(Booking.freelancer_id == freelancer_id).first()) or (None, 0)
    return (round(float(avg), 1) if avg else None), (count or 0)


def freelancer_services(freelancer_id):
    return (db.session.query(Service).join(FreelancerService)
            .filter(FreelancerService.freelancer_id == freelancer_id).all())


def categories_sorted():
    return ServiceCategory.query.order_by(ServiceCategory.service_category_name).all()


def platform_stats():
    return {
        "customers": Customer.query.count(),
        "freelancers": Freelancer.query.count(),
        "verified": Freelancer.query.filter_by(verification_status="verified").count(),
        "bookings": Booking.query.count(),
        "completed": Booking.query.filter_by(booking_status="completed").count(),
        "revenue": paid_total(None),
        "reviews": Review.query.count(),
        "open_reports": SafetyReport.query.filter_by(report_status="open").count(),
    }


def filtered(model, column, order, limit=None):
    """List query with an optional ?status= filter (used by the admin pages)."""
    status = request.args.get("status", "")
    q = model.query.filter_by(**{column: status}) if status else model.query
    q = q.order_by(order)
    return (q.limit(limit) if limit else q).all(), status


def save_image(field):
    """Validate and return an uploaded image, or None after flashing why not."""
    file = request.files.get(field)
    if not file or file.filename == "":
        flash("No file selected.", "error")
    elif not allowed_file(file.filename):
        flash("Allowed types: png, jpg, jpeg, gif, webp.", "error")
    else:
        return file
    return None

@app.route("/")
def home():
    top = Freelancer.query.filter_by(verification_status="verified").limit(6).all()
    for f in top:
        f.avg_rating, f.review_count = freelancer_avg_rating(f.freelancer_id)
    recent = Review.query.order_by(Review.review_date.desc()).limit(3).all()
    return render_template("index.html", stats=platform_stats(), categories=categories_sorted(),
                           top_freelancers=top, recent_reviews=recent)


@app.route("/about")
def about():
    return render_template("about.html", stats=platform_stats())


@app.route("/how-it-works")
def how_it_works():
    return render_template("how_it_works.html")

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        email = request.form.get("email", "").strip().lower()
        password = request.form.get("password", "")
        next_url = request.form.get("next") or request.args.get("next") or url_for("dashboard")

        for kind, model, email_col, id_col in USER_KINDS:
            user = model.query.filter(getattr(model, email_col).ilike(email)).first()
            if user and user.password_hash and check_password_hash(user.password_hash, password):
                session.clear()
                session.update(user_id=getattr(user, id_col), user_type=kind, user_name=user.full_name)
                if kind == "admin":
                    flash(f"Welcome, Admin {user.full_name}!", "success")
                    return redirect(url_for("admin_dashboard"))
                flash(f"Welcome back, {user.first_name}!", "success")
                return redirect(next_url if next_url.startswith("/") else url_for("dashboard"))
        flash("Invalid email or password.", "error")
    return render_template("login.html", next=request.args.get("next", ""))


@app.route("/logout")
def logout():
    session.clear()
    flash("You have been logged out.", "success")
    return redirect(url_for("home"))

@app.route('/change-password', methods=['GET', 'POST'])
def change_password():
    if 'user_id' not in session:
        flash('Please log in first.', 'danger')
        return redirect(url_for('login'))
        
    if request.method == 'POST':
        current_password = request.form.get('current_password')
        new_password = request.form.get('new_password')
        confirm_password = request.form.get('confirm_password')
        
        if new_password != confirm_password:
            flash('New passwords do not match.', 'danger')
            return redirect(url_for('change_password'))
            
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (session['user_id'],))
        user = cursor.fetchone()
        
        if not check_password_hash(user['password_hash'], current_password):
            flash('Incorrect current password.', 'danger')
            return redirect(url_for('change_password'))
            
        hashed_password = generate_password_hash(new_password)
        cursor.execute(
            "UPDATE users SET password_hash = %s WHERE user_id = %s",
            (hashed_password, session['user_id'])
        )
        db.commit()
        
        flash('Your password has been successfully updated!', 'success')
        
        if session.get('role') == 'admin':
            return redirect(url_for('admin_dashboard'))
        return redirect(url_for('dashboard'))

    return render_template('change_password.html')

def register(template, model, email_col, other_model, other_col, other_label, make_user, success):
    if request.method == "POST":
        email = request.form.get("email", "").strip().lower()
        pw = request.form.get("password", "")
        error = None
        if model.query.filter(getattr(model, email_col).ilike(email)).first():
            error = "An account with that email already exists."
        elif other_model.query.filter(getattr(other_model, other_col).ilike(email)).first():
            error = f"That email is already registered as a {other_label}."
        elif len(pw) < 6:
            error = "Password must be at least 6 characters."
        if error:
            flash(error, "error")
            return render_template(template)
        db.session.add(make_user(email, generate_password_hash(pw)))
        db.session.commit()
        flash(success, "success")
        return redirect(url_for("login"))
    return render_template(template)


@app.route("/register/customer", methods=["GET", "POST"])
def register_customer():
    f = request.form
    return register(
        "register_customer.html", Customer, "cus_email", Freelancer, "f_email", "freelancer",
        lambda email, pw: Customer(
            cus_first_name=f["first_name"].strip(), cus_last_name=f["last_name"].strip(),
            cus_phone_num=f["phone"].strip(), cus_email=email, password_hash=pw),
        "Customer account created! Please log in.")


@app.route("/register/freelancer", methods=["GET", "POST"])
def register_freelancer():
    f = request.form
    return register(
        "register_freelancer.html", Freelancer, "f_email", Customer, "cus_email", "customer",
        lambda email, pw: Freelancer(
            f_first_name=f["first_name"].strip(), f_last_name=f["last_name"].strip(),
            f_phone_num=f["phone"].strip(), f_email=email, password_hash=pw,
            verification_status="pending", bio=f.get("bio", "").strip()[:500] or None),
        "Freelancer account created! An admin will verify you soon. Please log in.")


@app.route("/forgot-password", methods=["GET", "POST"])
def forgot_password():
    if request.method == "POST":
        email = request.form.get("email", "").strip().lower()
        if find_by_email(email):
            token = serializer().dumps(email, salt="password-reset-salt")
            url = url_for("reset_password", token=token, _external=True)
            flash(f"Password reset link (demo – copy & open): {url}", "success")
        else:
            flash("If that email is registered, a reset link has been generated.", "success")
        return redirect(url_for("forgot_password"))
    return render_template("forgot_password.html")


@app.route("/reset-password/<token>", methods=["GET", "POST"])
def reset_password(token):
    try:
        email = serializer().loads(token, salt="password-reset-salt", max_age=3600)
    except SignatureExpired:
        flash("This reset link has expired. Please request a new one.", "error")
        return redirect(url_for("forgot_password"))
    except BadSignature:
        flash("Invalid reset link.", "error")
        return redirect(url_for("login"))

    if request.method == "POST":
        password, confirm = request.form.get("password", ""), request.form.get("confirm", "")
        error = ("Password must be at least 6 characters." if len(password) < 6
                 else "Passwords do not match." if password != confirm else None)
        if error:
            flash(error, "error")
            return render_template("reset_password.html", token=token)
        user = find_by_email(email)
        if not user:
            flash("Account not found.", "error")
            return redirect(url_for("login"))
        user.password_hash = generate_password_hash(password)
        db.session.commit()
        flash("Password updated successfully. Please log in.", "success")
        return redirect(url_for("login"))
    return render_template("reset_password.html", token=token)

@app.route("/dashboard")
@login_required
def dashboard():
    if session.get("user_type") == "admin":
        return redirect(url_for("admin_dashboard"))

    uid, is_customer = session["user_id"], session["user_type"] == "customer"
    col = Booking.customer_id if is_customer else Booking.freelancer_id
    extra = {"pending_count": Booking.query.filter(col == uid, Booking.booking_status == "pending").count()}
    if is_customer:
        extra["total_spent"] = paid_total(col, uid)
    else:
        extra["earnings"] = paid_total(col, uid)
        extra["avg_rating"], extra["review_count"] = freelancer_avg_rating(uid)
    recent = Booking.query.filter(col == uid).order_by(Booking.booking_date.desc()).limit(5).all()
    return render_template("dashboard.html", user=current_user(), recent_bookings=recent, **extra)


@app.route("/edit-profile", methods=["GET", "POST"])
@login_required
def edit_profile():
    if session.get("user_type") == "admin":
        return redirect(url_for("admin_dashboard"))
    user = current_user()
    if request.method == "POST":
        f, prefix = request.form, ("cus_" if session["user_type"] == "customer" else "f_")
        setattr(user, prefix + "first_name", f["first_name"].strip())
        setattr(user, prefix + "last_name", f["last_name"].strip())
        setattr(user, prefix + "phone_num", f["phone"].strip())
        if prefix == "f_":
            user.bio = f.get("bio", "").strip()[:500] or None
        session["user_name"] = user.full_name
        db.session.commit()
        flash("Profile updated.", "success")
        return redirect(url_for("dashboard"))
    return render_template("edit_profile.html", user=user)


@app.route("/upload-profile-pic", methods=["GET", "POST"])
@login_required
def upload_profile_pic():
    if session.get("user_type") == "admin":
        flash("Admins do not have profile pictures in this prototype.", "error")
        return redirect(url_for("admin_dashboard"))
    if request.method == "POST":
        file = save_image("profile_pic")
        if not file:
            return redirect(url_for("upload_profile_pic"))
        ext = os.path.splitext(secure_filename(file.filename))[1]
        filename = f"profile_{session['user_type']}_{session['user_id']}{ext}"
        file.save(os.path.join(app.config["UPLOAD_FOLDER"], filename))
        current_user().profile_pic = filename
        db.session.commit()
        flash("Profile picture updated.", "success")
        return redirect(url_for("dashboard"))
    return render_template("upload_profile_pic.html")

@app.route("/freelancers")
@login_required
def freelancers():
    q = request.args.get("q", "").strip()
    category_id = request.args.get("category", type=int)
    sort = request.args.get("sort", "name")

    query = Freelancer.query.filter_by(verification_status="verified")
    if q:
        like = f"%{q}%"
        query = query.filter(or_(Freelancer.f_first_name.ilike(like),
                                 Freelancer.f_last_name.ilike(like), Freelancer.bio.ilike(like)))
    if category_id:
        query = (query.join(FreelancerService).join(Service)
                 .filter(Service.service_category_id == category_id))
    found = query.distinct().all()
    for f in found:
        f.avg_rating, f.review_count = freelancer_avg_rating(f.freelancer_id)
        f.service_list = freelancer_services(f.freelancer_id)

    sort_keys = {"rating": (lambda x: x.avg_rating or 0, True),
                 "reviews": (lambda x: x.review_count, True)}
    key, reverse = sort_keys.get(sort, (lambda x: x.f_first_name.lower(), False))
    found.sort(key=key, reverse=reverse)
    return render_template("freelancers.html", freelancers=found, categories=categories_sorted(),
                           q=q, category_id=category_id, sort=sort)


@app.route("/freelancer/<int:freelancer_id>")
@login_required
def freelancer_profile(freelancer_id):
    freelancer = Freelancer.query.get_or_404(freelancer_id)
    reviews = (Review.query.join(Booking).filter(Booking.freelancer_id == freelancer_id)
               .order_by(Review.review_date.desc()).all())
    avg, count = freelancer_avg_rating(freelancer_id)
    return render_template(
        "freelancer_profile.html", freelancer=freelancer, reviews=reviews,
        portfolio=PortfolioImage.query.filter_by(freelancer_id=freelancer_id).all(),
        services=freelancer_services(freelancer_id), avg_rating=avg, review_count=count,
        completed_jobs=Booking.query.filter_by(freelancer_id=freelancer_id,
                                               booking_status="completed").count())

@app.route("/book/<int:freelancer_id>", methods=["GET", "POST"])
@login_required
@role_only("customer", "Only customers can book freelancers.")
def book_freelancer(freelancer_id):
    freelancer = Freelancer.query.get_or_404(freelancer_id)
    if freelancer.verification_status != "verified":
        flash("This freelancer is not yet verified.", "error")
        return redirect(url_for("freelancers"))

    def page():
        return render_template("book_freelancer.html", freelancer=freelancer,
                               services=freelancer_services(freelancer_id),
                               locations=Location.query.all())

    if request.method == "POST":
        f = request.form
        service_id, sched_date, sched_time = f.get("service_id"), f.get("scheduled_date"), f.get("scheduled_time")
        hours, rate = f.get("hours", type=float), f.get("rate", type=float)
        method = f.get("payment_method", "eft")

        error = None
        if not all([service_id, hours, rate, sched_date, sched_time]):
            error = "Please fill in all required fields."
        elif hours <= 0 or rate <= 0 or method not in ("cash", "card", "eft"):
            error = "Hours and rate must be above zero, and the payment method must be cash, card or EFT."
        else:
            try:
                if datetime.strptime(sched_date, "%Y-%m-%d").date() < date.today():
                    error = "Scheduled date cannot be in the past."
            except ValueError:
                error = "Invalid date."
        if error:
            flash(error, "error")
            return page()

        booking = Booking(booking_date=date.today(), scheduled_date=sched_date,
                          scheduled_time=sched_time, customer_id=session["user_id"],
                          freelancer_id=freelancer_id, location_id=int(f["location_id"]),
                          booking_status="pending")
        db.session.add(booking)
        db.session.flush()
        amount = round(Decimal(str(hours)) * Decimal(str(rate)), 2)
        db.session.add_all([
            BookingService(booking_id=booking.booking_id, service_id=int(service_id),
                           hours_booked=hours, agreed_hourly_rate=rate),
            Payment(booking_id=booking.booking_id, payment_method=method,
                    payment_date=date.today(), payment_amount=amount, payment_status="pending"),
        ])
        db.session.commit()
        flash(f"Booking #{booking.booking_id} created! Total: R{amount:.2f}. "
              "Awaiting freelancer confirmation.", "success")
        return redirect(url_for("my_orders"))
    return page()


def booking_list(owner_col, order, template, role, message):
    if session["user_type"] != role:
        flash(message, "error")
        return redirect(url_for("dashboard"))
    status = request.args.get("status", "")
    q = Booking.query.filter(owner_col == session["user_id"])
    if status:
        q = q.filter_by(booking_status=status)
    return render_template(template, bookings=q.order_by(order).all(), status_filter=status)


@app.route("/my-orders")
@login_required
def my_orders():
    return booking_list(Booking.customer_id, Booking.booking_date.desc(), "my_orders.html",
                        "customer", "Only customers can view orders.")


@app.route("/my-bookings")
@login_required
def my_bookings():
    return booking_list(Booking.freelancer_id, Booking.scheduled_date.desc(), "my_bookings.html",
                        "freelancer", "Only freelancers can view this page.")


@app.route("/cancel-booking/<int:booking_id>", methods=["POST"])
@login_required
def cancel_booking(booking_id):
    booking = Booking.query.get_or_404(booking_id)
    back = url_for("my_orders" if session["user_type"] == "customer" else "my_bookings")
    if not owns(booking):
        flash("Not authorized.", "error")
    elif booking.booking_status in ("completed", "cancelled"):
        flash("This booking cannot be cancelled.", "error")
    else:
        booking.booking_status = "cancelled"
        if booking.payment and booking.payment.payment_status == "pending":
            booking.payment.payment_status = "cancelled"
        db.session.commit()
        flash("Booking cancelled.", "success")
    return redirect(back)


def freelancer_action(booking_id, apply, message):
    """Shared by confirm/complete: only the booking's freelancer may act."""
    booking = Booking.query.get_or_404(booking_id)
    if booking.freelancer_id != session["user_id"]:
        flash("Not authorized.", "error")
    elif apply(booking):
        db.session.commit()
        flash(message, "success")
    return redirect(url_for("my_bookings"))


def _complete(booking):
    booking.booking_status = "completed"
    if booking.payment and booking.payment.payment_status == "pending":
        booking.payment.payment_status = "paid"
        booking.payment.payment_date = date.today()
    return True


def _confirm(booking):
    if booking.booking_status != "pending":
        return False
    booking.booking_status = "confirmed"
    return True


@app.route("/complete-booking/<int:booking_id>")
@login_required
def complete_booking(booking_id):
    return freelancer_action(booking_id, _complete, "Booking marked as completed. Payment recorded as paid.")


@app.route("/confirm-booking/<int:booking_id>")
@login_required
def confirm_booking(booking_id):
    return freelancer_action(booking_id, _confirm, "Booking confirmed. The customer has been notified (simulated).")


@app.route("/leave-review/<int:booking_id>", methods=["GET", "POST"])
@login_required
def leave_review(booking_id):
    booking = Booking.query.get_or_404(booking_id)
    error = ("Not authorized." if booking.customer_id != session["user_id"]
             else "You can only review a completed booking." if booking.booking_status != "completed"
             else "You have already reviewed this booking." if booking.review else None)
    if error:
        flash(error, "error")
        return redirect(url_for("my_orders"))

    if request.method == "POST":
        rating = int(request.form["rating"])
        if not 1 <= rating <= 5:
            flash("Rating must be between 1 and 5.", "error")
            return render_template("leave_review.html", booking=booking)
        db.session.add(Review(booking_id=booking_id, rating=rating, review_date=date.today(),
                              review_comment=request.form.get("comment", "").strip()[:300]))
        db.session.commit()
        flash("Thank you for your review!", "success")
        return redirect(url_for("my_orders"))
    return render_template("leave_review.html", booking=booking)


@app.route("/receipt/<int:booking_id>")
@login_required
def receipt(booking_id):
    booking = Booking.query.get_or_404(booking_id)
    if not owns(booking):
        abort(403)
    return render_template("receipt.html", booking=booking)


@app.route("/report/<int:booking_id>", methods=["GET", "POST"])
@login_required
def report_safety(booking_id):
    booking = Booking.query.get_or_404(booking_id)
    kind = session["user_type"]
    if kind == "admin":
        flash("Admins manage reports from the admin panel.", "error")
        return redirect(url_for("admin_reports"))
    if not owns(booking):
        flash("Not authorized.", "error")
        return redirect(url_for("dashboard"))

    if request.method == "POST":
        db.session.add(SafetyReport(
            booking_id=booking_id, report_type=kind, report_date=date.today(), report_status="open",
            report_reason=request.form["reason"].strip()[:100],
            report_description=request.form.get("description", "").strip()[:300]))
        db.session.commit()
        flash("Safety report submitted. Our team will review it.", "success")
        return redirect(url_for("dashboard"))
    return render_template("report_safety.html", booking=booking)


# ------------------------- Freelancer-only pages ----------------------------
@app.route("/my-services", methods=["GET", "POST"])
@login_required
@role_only("freelancer", "Only freelancers can manage services.")
def my_services():
    uid = session["user_id"]
    if request.method == "POST":
        FreelancerService.query.filter_by(freelancer_id=uid).delete()
        db.session.add_all(FreelancerService(freelancer_id=uid, service_id=int(sid))
                           for sid in request.form.getlist("services"))
        db.session.commit()
        flash("Your services have been updated.", "success")
        return redirect(url_for("my_services"))
    all_services = (Service.query.join(ServiceCategory)
                    .order_by(ServiceCategory.service_category_name, Service.service_name).all())
    mine = {fs.service_id for fs in FreelancerService.query.filter_by(freelancer_id=uid)}
    return render_template("my_services.html", services=all_services, my_service_ids=mine)


@app.route("/upload-portfolio", methods=["GET", "POST"])
@login_required
@role_only("freelancer", "Only freelancers can upload portfolio photos.")
def upload_portfolio():
    if request.method == "POST":
        file = save_image("portfolio_pic")
        if not file:
            return redirect(url_for("upload_portfolio"))
        base, ext = os.path.splitext(secure_filename(file.filename))
        filename = f"{base}_{session['user_id']}_{int(datetime.utcnow().timestamp())}{ext}"
        file.save(os.path.join(app.config["UPLOAD_FOLDER"], filename))
        db.session.add(PortfolioImage(filename=filename, freelancer_id=session["user_id"],
                                      caption=request.form.get("caption", "").strip()[:200]))
        db.session.commit()
        flash("Portfolio image uploaded.", "success")
        return redirect(url_for("freelancer_profile", freelancer_id=session["user_id"]))
    return render_template("upload_portfolio.html")


# -------------------------------- Admin panel -------------------------------
@app.route("/admin")
@login_required
@admin_required
def admin_dashboard():
    return render_template(
        "admin/dashboard.html", stats=platform_stats(),
        pending_freelancers=Freelancer.query.filter_by(verification_status="pending").all(),
        open_reports=(SafetyReport.query.filter_by(report_status="open")
                      .order_by(SafetyReport.report_date.desc()).limit(10).all()),
        recent_bookings=Booking.query.order_by(Booking.booking_date.desc()).limit(8).all())


@app.route("/admin/freelancers")
@login_required
@admin_required
def admin_freelancers():
    found, status = filtered(Freelancer, "verification_status", Freelancer.f_first_name)
    for f in found:
        f.avg_rating, f.review_count = freelancer_avg_rating(f.freelancer_id)
    return render_template("admin/freelancers.html", freelancers=found, status=status)


@app.route("/admin/verify/<int:freelancer_id>", methods=["POST"])
@login_required
@admin_required
def admin_verify(freelancer_id):
    f = Freelancer.query.get_or_404(freelancer_id)
    outcomes = {"verify": ("verified", "has been verified."),
                "reject": ("rejected", "has been rejected."),
                "pending": ("pending", "set back to pending.")}
    action = request.form.get("action")
    if action in outcomes:
        f.verification_status, text = outcomes[action]
        f.verification_date = None if action == "pending" else date.today()
        if action != "pending":
            f.admin_id = session["user_id"]
        flash(f"{f.full_name} {text}", "success")
    db.session.commit()
    return redirect(request.referrer or url_for("admin_freelancers"))


@app.route("/admin/reports")
@login_required
@admin_required
def admin_reports():
    reports, status = filtered(SafetyReport, "report_status", SafetyReport.report_date.desc())
    return render_template("admin/reports.html", reports=reports, status=status)


@app.route("/admin/report/<int:report_id>", methods=["POST"])
@login_required
@admin_required
def admin_update_report(report_id):
    report = SafetyReport.query.get_or_404(report_id)
    new_status = request.form.get("status")
    if new_status in ("open", "investigating", "resolved", "dismissed"):
        report.report_status = new_status
        db.session.commit()
        flash(f"Report #{report_id} updated to '{new_status}'.", "success")
    return redirect(url_for("admin_reports"))


@app.route("/admin/bookings")
@login_required
@admin_required
def admin_bookings():
    bookings, status = filtered(Booking, "booking_status", Booking.booking_date.desc(), limit=100)
    return render_template("admin/bookings.html", bookings=bookings, status=status)


@app.route("/admin/customers")
@login_required
@admin_required
def admin_customers():
    return render_template("admin/customers.html",
                           customers=Customer.query.order_by(Customer.cus_first_name).all())

# ----------------------- Admin: delete data --------------------------------
def delete_bookings(booking_ids):
    """Remove bookings plus everything that points at them (child rows first)."""
    if not booking_ids:
        return
    for model in (BookingService, Payment, Review, SafetyReport):
        model.query.filter(model.booking_id.in_(booking_ids)).delete(synchronize_session=False)
    Booking.query.filter(Booking.booking_id.in_(booking_ids)).delete(synchronize_session=False)


@app.route("/admin/delete/<kind>/<int:item_id>", methods=["POST"])
@login_required
@admin_required
def admin_delete(kind, item_id):
    if kind == "booking":
        Booking.query.get_or_404(item_id)
        delete_bookings([item_id])
        label, back = f"Booking #{item_id}", "admin_bookings"
    elif kind == "customer":
        c = Customer.query.get_or_404(item_id)
        delete_bookings([b.booking_id for b in Booking.query.filter_by(customer_id=item_id)])
        label, back = c.full_name, "admin_customers"
        db.session.delete(c)
    elif kind == "freelancer":
        f = Freelancer.query.get_or_404(item_id)
        delete_bookings([b.booking_id for b in Booking.query.filter_by(freelancer_id=item_id)])
        PortfolioImage.query.filter_by(freelancer_id=item_id).delete()
        FreelancerService.query.filter_by(freelancer_id=item_id).delete()
        label, back = f.full_name, "admin_freelancers"
        db.session.delete(f)
    else:
        abort(404)
    db.session.commit()
    flash(f"{label} was deleted.", "success")
    return redirect(url_for(back))


# ----------------------- Admin: analytics reports --------------------------
REPORT_QUERIES = [
    ("Top-rated freelancers", ["Freelancer", "Avg rating", "Reviews"],
     """SELECT CONCAT(f.f_first_name, ' ', f.f_last_name), ROUND(AVG(r.rating), 1), COUNT(r.review_id)
        FROM freelancer f JOIN booking b ON b.freelancer_id = f.freelancer_id
        JOIN review r ON r.booking_id = b.booking_id
        GROUP BY f.freelancer_id ORDER BY 2 DESC, 3 DESC LIMIT 10"""),
    ("Bookings by status", ["Status", "Bookings"],
     "SELECT booking_status, COUNT(*) FROM booking GROUP BY booking_status ORDER BY 2 DESC"),
    ("Revenue by service category (excl. cancelled)", ["Category", "Bookings", "Value (R)"],
     """SELECT sc.service_category_name, COUNT(DISTINCT b.booking_id),
               ROUND(SUM(bs.hours_booked * bs.agreed_hourly_rate), 2)
        FROM booking_service bs JOIN booking b ON b.booking_id = bs.booking_id
        JOIN service s ON s.service_id = bs.service_id
        JOIN service_category sc ON sc.service_category_id = s.service_category_id
        WHERE b.booking_status <> 'cancelled'
        GROUP BY sc.service_category_id ORDER BY 3 DESC"""),
    ("Freelancers by verification status", ["Status", "Freelancers"],
     "SELECT verification_status, COUNT(*) FROM freelancer GROUP BY verification_status"),
    ("Busiest locations", ["Location", "Municipality", "Bookings"],
     """SELECT l.location_name, l.municipality_name, COUNT(b.booking_id)
        FROM location l LEFT JOIN booking b ON b.location_id = l.location_id
        GROUP BY l.location_id ORDER BY 3 DESC"""),
]


@app.route("/admin/analytics")
@login_required
@admin_required
def admin_analytics():
    reports = [{"title": t, "columns": c, "rows": db.session.execute(text(q)).fetchall()}
               for t, c, q in REPORT_QUERIES]
    return render_template("admin/analytics.html", reports=reports)

# ----------------------- Admin: per-category report ------------------------
CATEGORY_REPORT_SQL = """
    SELECT b.booking_id, b.scheduled_date, s.service_name,
           c.cus_first_name, c.cus_last_name, f.f_first_name, f.f_last_name,
           l.location_name, bs.hours_booked, bs.agreed_hourly_rate,
           ROUND(bs.hours_booked * bs.agreed_hourly_rate, 2) AS line_total,
           b.booking_status, p.payment_status
    FROM booking_service bs
    JOIN booking b    ON b.booking_id = bs.booking_id
    JOIN service s    ON s.service_id = bs.service_id
    JOIN customer c   ON c.customer_id = b.customer_id
    JOIN freelancer f ON f.freelancer_id = b.freelancer_id
    JOIN location l   ON l.location_id = b.location_id
    LEFT JOIN payment p ON p.booking_id = b.booking_id
    WHERE s.service_category_id = :cid
    ORDER BY b.scheduled_date DESC, b.booking_id DESC"""


@app.route("/admin/category-report")
@login_required
@admin_required
def admin_category_report():
    """Report for ONE service category (e.g. Electrical & Wiring), printable on its own."""
    category_id = request.args.get("category", type=int)
    category = db.session.get(ServiceCategory, category_id) if category_id else None
    if category_id and not category:
        abort(404)
    rows, summary = [], None
    if category:
        rows = db.session.execute(text(CATEGORY_REPORT_SQL), {"cid": category.service_category_id}).fetchall()
        active = [r for r in rows if r.booking_status != "cancelled"]
        summary = {
            "bookings": len({r.booking_id for r in rows}),
            "completed": len({r.booking_id for r in rows if r.booking_status == "completed"}),
            "cancelled": len({r.booking_id for r in rows if r.booking_status == "cancelled"}),
            "hours": sum((Decimal(str(r.hours_booked)) for r in active), Decimal(0)),
            "value": sum((Decimal(str(r.line_total)) for r in active), Decimal(0)),
            "freelancers": len({(r.f_first_name, r.f_last_name) for r in active}),
        }
    return render_template("admin/category_report.html", categories=categories_sorted(),
                           category=category, rows=rows, summary=summary, generated=datetime.now())

# ----------------------- Admin: create / drop tables -----------------------
CORE_TABLES = {m.__tablename__ for m in db.Model.__subclasses__()}
NAME_RE = re.compile(r"^[a-z][a-z0-9_]{0,39}$")
COLUMN_TYPES = {"Whole number": "INT", "Text (up to 100)": "VARCHAR(100)", "Long text": "TEXT",
                "Date": "DATE", "Decimal": "DECIMAL(10,2)"}


def existing_tables():
    return inspect(db.engine).get_table_names()


def custom_tables():
    return sorted(t for t in existing_tables() if t not in CORE_TABLES)


def custom_table_or_404(name):
    if name not in custom_tables() or not NAME_RE.match(name):
        abort(404)
    return name


@app.route("/admin/tables")
@login_required
@admin_required
def admin_tables():
    return render_template("admin/tables.html", tables=custom_tables(),
                           core=sorted(CORE_TABLES), types=COLUMN_TYPES)


@app.route("/admin/tables/create", methods=["POST"])
@login_required
@admin_required
def admin_create_table():
    name = request.form.get("table_name", "").strip().lower()
    cols = [(n.strip().lower(), t) for n, t in
            zip(request.form.getlist("col_name"), request.form.getlist("col_type")) if n.strip()]
    names = [n for n, _ in cols]
    if not NAME_RE.match(name):
        flash("Table name: lowercase letters, digits, underscores; must start with a letter.", "error")
    elif name in existing_tables():
        flash(f"A table called '{name}' already exists.", "error")
    elif not cols:
        flash("Add at least one column.", "error")
    elif any(not NAME_RE.match(n) or n == "id" for n in names) or len(set(names)) != len(names):
        flash("Column names must be unique, lowercase, valid, and not 'id' (added automatically).", "error")
    elif any(t not in COLUMN_TYPES for _, t in cols):
        flash("Invalid column type.", "error")
    else:
        defs = ", ".join(f"`{n}` {COLUMN_TYPES[t]} NULL" for n, t in cols)
        try:
            db.session.execute(text(f"CREATE TABLE `{name}` (id INT PRIMARY KEY AUTO_INCREMENT, {defs})"))
            db.session.commit()
            flash(f"Table '{name}' created.", "success")
        except SQLAlchemyError as e:
            db.session.rollback()
            flash(f"Could not create table: {getattr(e, 'orig', e)}", "error")
    return redirect(url_for("admin_tables"))


@app.route("/admin/tables/drop/<name>", methods=["POST"])
@login_required
@admin_required
def admin_drop_table(name):
    custom_table_or_404(name)  # core tables can never be dropped
    try:
        db.session.execute(text(f"DROP TABLE `{name}`"))
        db.session.commit()
        flash(f"Table '{name}' removed.", "success")
    except SQLAlchemyError as e:
        db.session.rollback()
        flash(f"Could not remove table: {getattr(e, 'orig', e)}", "error")
    return redirect(url_for("admin_tables"))


@app.route("/admin/tables/<name>")
@login_required
@admin_required
def admin_table_view(name):
    custom_table_or_404(name)
    cols = [c["name"] for c in inspect(db.engine).get_columns(name)]
    rows = db.session.execute(text(f"SELECT * FROM `{name}` ORDER BY id DESC LIMIT 100")).fetchall()
    return render_template("admin/table_view.html", name=name, cols=cols, rows=rows)


@app.route("/admin/tables/<name>/add", methods=["POST"])
@login_required
@admin_required
def admin_table_add_row(name):
    custom_table_or_404(name)
    cols = [c["name"] for c in inspect(db.engine).get_columns(name) if c["name"] != "id"]
    values = {c: (request.form.get(c, "").strip() or None) for c in cols}
    col_sql = ", ".join(f"`{c}`" for c in cols)
    val_sql = ", ".join(f":{c}" for c in cols)
    try:
        db.session.execute(text(f"INSERT INTO `{name}` ({col_sql}) VALUES ({val_sql})"), values)
        db.session.commit()
        flash("Row added.", "success")
    except SQLAlchemyError as e:
        db.session.rollback()
        flash(f"Could not add row: {getattr(e, 'orig', e)}", "error")
    return redirect(url_for("admin_table_view", name=name))


@app.route("/admin/tables/<name>/delete/<int:row_id>", methods=["POST"])
@login_required
@admin_required
def admin_table_delete_row(name, row_id):
    custom_table_or_404(name)
    db.session.execute(text(f"DELETE FROM `{name}` WHERE id = :i"), {"i": row_id})
    db.session.commit()
    flash("Row deleted.", "success")
    return redirect(url_for("admin_table_view", name=name))


TRIGGER_MESSAGES = {
    50001: "Only verified freelancers can be booked.",
    50002: "A review can only be added for a completed booking.",
    50003: "The payment date cannot be before the booking date.",
}


@app.errorhandler(DBAPIError)
def database_rule_error(e):
    db.session.rollback()
    code = e.orig.args[0] if getattr(e, "orig", None) and e.orig.args else None
    if code in TRIGGER_MESSAGES:
        flash(TRIGGER_MESSAGES[code], "error")
    elif code == 3819:  # MySQL: CHECK constraint violated
        flash("That request breaks a database rule (invalid value). Please check your input.", "error")
    else:
        raise e
    return redirect(request.referrer or url_for("home"))


for _code in (403, 404, 500):
    app.register_error_handler(_code, lambda e, c=_code: (render_template(f"errors/{c}.html"), c))


@app.context_processor
def inject_globals():
    return {"current_user": current_user(), "now": datetime.utcnow}


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)