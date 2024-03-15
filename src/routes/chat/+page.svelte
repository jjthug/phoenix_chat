<script>
    export let roomId;
    export let userId;
    import { goto } from '$app/navigation';

    // Function to handle the redirection
    function redirectToRoom() {
        if (roomId.trim() !== '') {
            goto(`/chat/${roomId}?userId=${userId}`);
        }
    }
</script>

<main>
    <h1>Enter Room ID</h1>
    <input type="text" bind:value={roomId} placeholder="Room ID">
    <h1>Enter User ID</h1>
    <input type="text" bind:value={userId} placeholder="User ID">
    <button on:click={redirectToRoom}>Go to Chat Room</button>
</main>

<style>
    /* Add styles if necessary */
</style>