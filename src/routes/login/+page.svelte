<script>
    import { goto } from '$app/navigation';

    let username = '';
    let password = '';
    let errorMessage = ''; // To store and display any error messages

    // Placeholder function to handle custom login
    async function handleLogin(event) {
        event.preventDefault();
        errorMessage = ''; // Reset error message on new login attempt

        try {
            const response = await fetch('/api/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ username, password }),
            });

            if (!response.ok) {
                // If the server response is not OK, throw an error with the response
                const errorData = await response.json();
                throw new Error(errorData.message || 'Failed to login');
            }

            // Assuming the server responds with JSON data including a redirect URL or user data
            const data = await response.json();

            // Here you might want to update global state with the logged-in user's data
            // For example, using a writable store or SvelteKit's session store

            // Redirect the user after successful login
            goto('/profile'); // Adjust the redirect URL as needed
        } catch (error) {
            // Handle any errors that occurred during fetch
            errorMessage = error.message;
        }
    }

    // Function to navigate to the signup page
    function goToSignUp() {
        goto('/signup'); // Adjust this to your signup route
    }
</script>

<h2>Login</h2>

<form on:submit={handleLogin}>
    <div class="form-group">
        <label for="username">Username:</label>
        <input id="username" type="text" bind:value={username}>
    </div>

    <div class="form-group">
        <label for="password">Password:</label>
        <input id="password" type="password" bind:value={password}>
    </div>

    <button type="submit" class="btn">Login</button>
    {#if errorMessage}
        <p class="error">{errorMessage}</p>
    {/if}
</form>

<p>
    <a href="/signup" on:click|preventDefault={goToSignUp}>Don't have an account? Sign up</a>
</p>

<style>
    /* Add your CSS here */
</style>