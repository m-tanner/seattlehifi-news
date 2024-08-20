import React, {useState} from "react";

const frontEndURL = process.env.REACT_APP_FRONTEND_BASE_URL;

const AuthForm = () => {
    const [email, setEmail] = useState('');
    const [message, setMessage] = useState('');
    const [submitted, setSubmitted] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setMessage(''); // Reset message state

        try {
            const response = await fetch(`/api/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ email_address: email, url: `${frontEndURL}/user-profile/` }),
            });

            if (!response.ok) {
                throw new Error('Failed to submit form');
            }
            setSubmitted(true);
        } catch (error) {
            setMessage(`Error: ${error.message}`);
            console.error('Error:', error);
        }
    };

    // Render the "check your email" message if the form has been submitted
    if (submitted) {
        return (
            <div className="auth-form-container">
                <h2>Check Your Email</h2>
                <p>We've sent you an email with further instructions. Please check your inbox.</p>
            </div>
        );
    }

    // Render the form by default
    return (
        <div className="auth-form-container">
            <h2>Login or Sign Up</h2>
            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label htmlFor="email">Email Address:</label>
                    <input
                        type="email"
                        id="email"
                        name="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                    />
                </div>
                <button type="submit">Submit</button>
                {message && <p>{message}</p>}
            </form>
        </div>
    );
};

export default AuthForm;