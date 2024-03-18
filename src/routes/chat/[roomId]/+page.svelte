<script>
    import { onMount } from 'svelte';
    import { Socket } from 'phoenix';
    import { page } from '$app/stores';

    let socket;
    let channel;
    let message = '';
    let messages = [];
    let users = [];
    let userSet = new Set();
    let userId;
    let roomId;
    let isInit = false;
    let typingUsersSet = new Set();
    let typingUsers=[];

    let localuserId;

    onMount(() => {
        // console.log("$page.params =>",$page.params)
        roomId = $page.params.roomId;
        // console.log("roomId =>",roomId)

        let userId = $page.url.searchParams.get('userId');

        function toUser(user){
            return String(user).split("//")[0];
        }

        // for (let i=0;i < 200; i++){

        // localuserId=`${userId}_${i}`
        localuserId=userId

        // console.log(`started ${i}`)

        // Replace 'ws://localhost:4000/socket' with your actual WebSocket endpoint
        // socket = new Socket('wss://chat-app-dev.fly.dev/socket',{params: {user_id: userId, room_id: roomId}});
        socket = new Socket('ws://localhost:4000/socket',{params: {user_id: localuserId, room_id: roomId}});

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
            // console.log("payload=>",payload)
            messages = [...messages, { user: toUser(payload.username), text: payload.text }];
        });

        // Listen for presence state and diffs
        channel.on("presence_state", state => {
            if (!isInit) {
                isInit = true;

                // typingUsers = Object.keys(state).filter(usr => {console.log(state[usr].metas[0].isTyping);
                // return state[usr].metas[0].isTyping == true;})

                // let typingUsersUniq = users.map(usr=>usr.split("//")[0])
                // typingUsersSet = new Set(typingUsersUniq);


                // console.log("typingUsers=>",typingUsers);
                // console.log("state=>",state);

                let allUsers = Object.keys(state)
                users=[...new Set([...users, ...allUsers])];
                let usersUniq = users.map(usr=>usr.split("//")[0])
                userSet = new Set(usersUniq);
                // console.log("presence state:", state);
            }
        });

        channel.on("presence_diff", diff => {
            if(isInit) {
                if (Object.keys(diff.leaves).length > 0) {
                    let usersToRemove = Object.keys(diff.leaves)
                    // console.log("usersToRemove =>", usersToRemove)
                    users = users.filter(user => !usersToRemove.includes(user));
                    let usersUniq = users.map(usr=>usr.split("//")[0])
                    userSet=new Set(usersUniq);

                    // //typing users
                    // let typingusersToRemove = Object.keys(diff.leaves).filter(usr => diff.leaves[usr].metas[0].isTyping == false)
                    // console.log("typingusersToRemove =>", typingusersToRemove)
                    // typingUsers = typingUsers.filter(user => !typingusersToRemove.includes(user));
                    // let typingusersUniq = typingUsers.map(usr=>usr.split("//")[0])
                    // typingUsersSet=new Set(typingusersUniq);
                }
                if (Object.keys(diff.joins).length > 0) {
                    let newUsers = Object.keys(diff.joins)
                    users = [...new Set([...users, ...newUsers])];
                    let usersUniq = users.map(usr=>usr.split("//")[0])
                    userSet=new Set(usersUniq);

                    // //typing users
                    // let newtypingUsers = Object.keys(diff.joins).filter(usr => diff.joins[usr].metas[0].isTyping == true)
                    // typingUsers = [...new Set([...typingUsers, ...newtypingUsers])];
                    // let typingusersUniq = typingUsers.map(usr=>usr.split("//")[0])
                    // typingUsersSet=new Set(typingusersUniq);
                }

            }

       });
    // }


    });

    // Function to send a message
    function sendMessage() {
        if (message.trim() !== '') {
            channel.push('new_msg', { chatmsg: message });
            message = '';
        }
    }

    function changeMessage() {
        console.log("change message pushing");
        channel.push('change_msg', { chatmsg: message });
    }

</script>

<main>
    <h1>Phoenix Chat</h1>
    <br>
    <h2>Online users</h2>
    <ul>
        {#each userSet as user}
            <li>{user}</li>
        {/each}
    </ul>

    <h2>Typing users</h2>
    <ul>
        {#each typingUsersSet as user}
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
            <li><b>{msg.user}:</b>{msg.text}</li>
        {/each}
    </ul>
</main>

<style>
    /* Add styling as needed */
</style>