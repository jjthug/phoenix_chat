<script>
    import { onMount } from 'svelte';
    import { Socket } from 'phoenix';
    import { page } from '$app/stores';

    let socket;
    let channel;
    let message = '';
    let messages = [];
    let userId;
    let roomId;

    onMount(() => {
        console.log("$page.params =>",$page.params)
        roomId = $page.params.roomId;
        console.log("roomId =>",roomId)

        userId = $page.url.searchParams.get('userId');

        // Replace 'ws://localhost:4000/socket' with your actual WebSocket endpoint
        socket = new Socket('ws://localhost:4000/socket',{params: {user_id: userId, room_id: roomId}});
        socket.connect();

        // Join the channel
        channel = socket.channel(`room:${roomId}`, {});
        channel.join()
            .receive('ok', () => {
                console.log('Successfully joined the channel');
            })
            .receive('error', (resp) => {
                console.log('Unable to join the channel', resp);
            });

        // Listen for incoming messages
        channel.on('new_msg', (payload) => {
            console.log("payload=>",payload)
            messages = [...messages, payload.text];
        });
    });

    // Function to send a message
    function sendMessage() {
        if (message.trim() !== '') {
            channel.push('new_msg', { chatmsg: message });
            message = '';
        }
    }
</script>

<main>
    <h1>Phoenix Chat</h1>
    <input
            type="text"
            placeholder="Type a message..."
            bind:value={message}
            on:keydown={(e) => e.key === 'Enter' && sendMessage()}
    />
    <button on:click={sendMessage}>Send</button>

    <ul>
        {#each messages as msg}
            <li>{msg}</li>
        {/each}
    </ul>
</main>

<style>
    /* Add styling as needed */
</style>