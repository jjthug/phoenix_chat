<script>
    import { goto } from '$app/navigation';
    import { browser } from '$app/environment'; // Import to check if code runs in the browser
    import {
        PUBLIC_SERVER_URL
    } from '$env/static/public';
    let username = '';
    let password = '';
    let aboutUser = '';
    let errorMessage = '';

    function countWords(str) {
        return str.trim().split(/\s+/).length;
    }

    async function handleSignup(event) {
        event.preventDefault();

        // Ensure this runs only in the browser, as environment variables
        // are replaced at build time and might be used in browser context.
        if (!browser) return;

        if (countWords(aboutUser) < 10) {
            errorMessage = 'The about text must be at least 10 words.';
            return;
        }

        const signupUrl = `${PUBLIC_SERVER_URL}/signup`; // Use the SERVER_URL environment variable

        try {
            const response = await fetch(signupUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    username,
                    password,
                    doc: aboutUser,
                }),
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.message || 'Failed to sign up');
            }

            const { verify_code } = await response.json();
            goto(`/verify_email?verify_code=${verify_code}`);
        } catch (error) {
            errorMessage = error.message;
        }
    }
</script>
<form on:submit={handleSignup}>
    <div>
        <label for="username">Username</label>
        <input id="username" type="text" bind:value={username} minlength="3">
    </div>

    <div>
        <label for="password">Password</label>
        <input id="password" type="password" bind:value={password}>
    </div>

    <div>
        <label for="aboutUser">About</label>
        <textarea id="aboutUser" bind:value={aboutUser}></textarea>
    </div>

    {#if errorMessage}
        <p class="error">{errorMessage}</p>
    {/if}

    <button type="submit">Sign Up</button>
</form>

<style>
    .error {
        color: red;
    }
    /* Additional styling here */
</style>
