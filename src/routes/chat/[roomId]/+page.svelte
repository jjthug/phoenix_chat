<script>
    import { onMount } from 'svelte';
    import { Socket } from 'phoenix';
    import { page } from '$app/stores';

    let socket;
    let channel;
    let message = '';
    let messages = [];
    let users = [];
    let userId;
    let roomId;
    let isInit = false;

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

        // Listen for presence state and diffs
        channel.on("presence_state", state => {
            if (!isInit) {
                let allUsers = Object.keys(state)
                users = [...new Set([...users, ...allUsers])];
                isInit = true;
                console.log("presence state:", state);
            }
        });

        channel.on("presence_diff", diff => {
            if(isInit) {
                if (Object.keys(diff.leaves).length > 0) {
                    let usersToRemove = Object.keys(diff.leaves)
                    console.log("usersToRemove =>", usersToRemove)
                    users = users.filter(user => !usersToRemove.includes(user));
                }
                if (Object.keys(diff.joins).length > 0) {
                    let newUsers = Object.keys(diff.joins)
                    users = [...new Set([...users, ...newUsers])];
                }
                console.log("presence diff:", diff);
            }
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
    <br>
    <h2>Online users</h2>
    <ul>
        {#each users as user}
            <li>{user}</li>
        {/each}
    </ul>

<br>
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